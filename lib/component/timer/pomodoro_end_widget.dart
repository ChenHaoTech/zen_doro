import 'dart:async';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:duration/duration.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/component/editor/task_editor.dart';
import 'package:flutter_pasteboard/component/fn_popMenu.dart';
import 'package:flutter_pasteboard/component/short_cut/ShortProvider.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:flutter_pasteboard/component/short_cut/short_cut_view.dart';
import 'package:flutter_pasteboard/component/time_block_widget/timeblock_edit_extension.dart';
import 'package:flutter_pasteboard/component/timer/feedback_const.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/fn_notification.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/model/misc.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/screens/mobile/timeblock/timeblock_edit_mobile.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:flutter_pasteboard/service/time_block_store.dart';
import 'package:flutter_pasteboard/service/time_rule_misc.dart';
import 'package:flutter_pasteboard/service/window_service.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:ui_extension/ui_extension.dart';

class PomodoroEndWidget extends StatefulWidget {
  final TimeBlock tb;

  PomodoroEndWidget({super.key, required this.tb});

  @override
  State<PomodoroEndWidget> createState() => _PomodoroEndWidgetState();
}

class _PomodoroEndWidgetState extends State<PomodoroEndWidget> with KeyBoardArrowMixin implements ITimeBlockEditor {
  late final Rx<TimeBlock> _tbRx = Rx(widget.tb);
  final titleFocusNode = FocusNode();
  final contextFieldFocusNode = FocusNode();
  final durationFocusNode = FocusNode();
  final timeFieldFocusNode = FocusNode();
  var focusNode = FocusNode();
  late final textEditingController = TextEditingController(text: tbRx.justValue.pomodoro.title ?? "");
  late Future<TimeBlock?> lastTbFuture;

  @override
  List<FocusNode> get focusNodeList => [
        titleFocusNode,
        timeFieldFocusNode,
        durationFocusNode,
        contextFieldFocusNode,
      ];
  final selectedEmotion = 0.obs;
  final formate = DateFormat('HH:mm');
  late final ExpandableController controller = ExpandableController(initialExpanded: SettingService.instance.endFeedbackShowTime.value);
  final Rx<Timer?> _timer = Rx(null);
  final Rx<int?> _leftSeconds = Rx(null);

  void startCountDown() {
    _reset();
    var duration = 1.minutes;
    _leftSeconds.value = duration.inSeconds;
    _timer.value = Timer.periodic(1.seconds, (_) {
      var originV = _leftSeconds.value;
      if (originV == null) {
        _reset();
        return;
      }
      var val = originV - 1;
      _leftSeconds.value = val;
      if (val < 0) {
        _reset();
        close();
      }
    });
  }

  void _reset() {
    _timer.value?.cancel();
    _timer.value = null;
    _leftSeconds.value = null;
  }

  @override
  void initState() {
    super.initState();
    startCountDown();
    var sh = SettingService.instance.endFeedbackShowTime;
    sh.init.then((value) => controller.expanded = sh.value);
    controller.addListener(() {
      sh.value = controller.expanded;
    });
    if (tbRx.justValue.startTime == null) {
      tbRx.justValue = tbRx.justValue.updateTime(startTime: DateTime.now());
    }
    tbRx.justValue = tbRx.justValue.updateTime(endTime: DateTime.now());
    lastTbFuture = TimeBlockStore.find.getRecent(0, 2).then((value) => value..removeWhere((e) => e.uuid == tbRx.justValue.uuid)).then(
          (value) => value.getNullable(0),
        );

    _tbRx.listen((p0) {
      _reset();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  TimeBlock get _resultTb {
    var justValue = tbRx.justValue;
    var diffDuration = justValue.endTime!.difference(justValue.startTime!);
    if (diffDuration.isNegative) {
      BotToast.showText(text: "开始时间大于完成时间".i18n);
      return justValue;
    }
    return justValue.updatePromodo(
      mapper: (p0) {
        return p0.copyWith(
          feedback: feedbackEmojis[selectedEmotion.justValue],
        );
      },
    );
  }

  void submit() async {
    var timeBlock = _resultTb;
    await $zenService.updateTimeBlock(timeBlock);
    if ($zenService.isFocus) {
      close();
      return;
    }
    var unit = TimeRuleController.find.getCurPomodoroUnit();
    // DebugUtils.log("pomodoro_end_widget:150: ${unit.isRest} \n${StackTrace.current}");
    if (unit.isRest) {
      if (SettingService.instance.autoRest.value) {
        await $zenService.startRest(unit.buildTb());
      }
    } else {
      // todo next task
      await $zenService.updateTimeBlock(unit.buildTb());
    }
    close();
  }

  void close() {
    if ($zenService.feedbackLocker.isCompleted) {
      Get.back();
      return;
    }
    $zenService.feedbackLocker.release();
    runOnNextFrame(() {
      if ($zenService.state == PomodoroState.FocusFeedBack) {
        $zenService.state = PomodoroState.Edit;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var scaffold = _buildInnerAdaptive(context)
        .safeArea()
        .focus(onKey: (_, event) {
          _reset();
          // 如果是 1~5 之间, 就修改selectedEmotion
          if (!event.isAltPressed) return KeyEventResult.ignored;
          var idx = FnKeys.num1_9.findIdx((p0) => p0 == event.logicalKey);
          if (idx != null) {
            selectedEmotion.value = clampInt(idx, 0, feedbackEmojis.length - 1);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        })
        .blurOnUnFocus()
        .simpleShortcuts({
          FnKeys.cmdEnter: () {
            submit();
          },
          FnActions.DiscardCurrentFocus: () async {
            await $zenService.discardFocus(requestTb: $zenService.lastEndFocusTb);
            close();
          },
          FnActions.FocusNext: () {
            focusNodeList.next();
          },
          FnActions.FocusPrevious: () {
            focusNodeList.reversed.next();
          },
          FnKeys.cmdS: () {
            submit();
          },
          FnActions.AddFiveMinutes: () {
            _addTime();
          },
          FnKeys.cmdT: () {
            controller.toggle();
            if (controller.expanded) {
              runOnNextFrame(() => timeFieldFocusNode.requestFocus());
            }
          }
        }, debug: "end_widget");
    return ShortcutRooter(
      child: scaffold,
    );
  }

  Widget _buildInnerAdaptive(BuildContext context) {
    if (PlatformUtils.isMobile) {
      return KeyboardActions(
          disableScroll: true,
          config: KeyboardActionsConfig(keyboardBarColor: context.background, actions: [
            buildSimpleKAI(
              focusNode: titleFocusNode,
              child: Row(
                children: [
                  Spacer(),
                  ...arrowBtns,
                ],
              ),
            ),
            buildSimpleKAI(
              focusNode: focusNode,
              child: Row(
                children: [
                  ..._buildTimeQuickTool().insertBetween(() => gap4),
                  Spacer(),
                  ...arrowBtns,
                ],
              ),
            ),
            buildSimpleKAI(
              focusNode: durationFocusNode,
              child: Row(
                children: [
                  Spacer(),
                  ...arrowBtns,
                ],
              ),
            ),
            buildSimpleKAI(
              focusNode: contextFieldFocusNode,
              child: Row(
                children: [
                  Spacer(),
                  ...arrowBtns,
                ],
              ),
            ),
          ]),
          child: _buildInner(context).easyTap(onTap: () {
            _reset();
          }));
    } else {
      return _buildInner(context);
    }
  }

  Scaffold _buildInner(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          LayoutBuilder(builder: (BuildContext context, c) {
            var scale = min(c.maxHeight / promodoSize.height, c.maxWidth / promodoSize.width);
            var text = prettyDuration(
              (tbRx.value.endTime!.difference(tbRx.value.startTime!).inSeconds - tbRx.value.pomodoro.pauseSeconds).seconds,
              tersity: DurationTersity.minute,
            );
            return Column(
              children: [
                Text("暂停下,做个复盘 🧠".i18n).opacity(.3),
                Obx(() => RichText(
                      text: TextSpan(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32 * scale,
                            color: context.onBackground,
                          ),
                          children: [
                            TextSpan(text: "你已经专注了// 后面跟着一个具体的时间长度".i18n),
                            TextSpan(
                              text: text,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 48 * scale,
                                decoration: TextDecoration.underline,
                                decorationColor: context.primary,
                              ),
                            ),
                          ]),
                    )),
                gap12,
                Builder(builder: (_) {
                  if (PlatformUtils.isDesktop || PlatformUtils.isWeb) {
                    return TaskEditor(
                      initTag: tbRx.justValue.tags.firstOrNull,
                      reverse: false,
                      autofocus: false,
                      focusNode: titleFocusNode,
                      controller: textEditingController,
                      onChanged: (String val) {
                        tbRx.value = tbRx.justValue.updateFocus(title: val);
                      },
                      onTagUpdate: (Tag? tag) {
                        tbRx.value = tbRx.justValue.updateFocus(
                          tag: tag,
                          isDeleteTag: tag == null,
                        );
                      },
                    );
                  } else {
                    return TaskEditorSimple(
                      initTag: tbRx.justValue.tags.firstOrNull,
                      autofocus: false,
                      focusNode: titleFocusNode,
                      controller: textEditingController,
                      onChanged: (String val) {
                        tbRx.value = tbRx.justValue.updateFocus(title: val);
                      },
                      onTagUpdate: (Tag? tag) {
                        tbRx.value = tbRx.justValue.updateFocus(
                          tag: tag,
                          isDeleteTag: tag == null,
                        );
                      },
                    );
                  }
                }),
                ExpandablePanel(
                  controller: controller,
                  theme: ExpandableThemeData(
                    iconColor: context.defaultTextColor.withOpacity(.6),
                    hasIcon: context.isMobile,
                  ),
                  header: ListTile(
                    title: Obx(
                      () {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(FnDateUtils.humanReadable(tbRx.value.startTime!)),
                            gap4,
                            Icon(
                              FnIcons.text_right,
                              size: 12,
                            ),
                            gap4,
                            Text(FnDateUtils.humanReadable(tbRx.value.endTime)),
                          ],
                        );
                      },
                    ),
                    trailing: context.isMobile
                        ? null
                        : Text(
                            "${FnKeys.cmdT.toReadable()}",
                            style: context.defaultTextStyle.copyWith(decoration: TextDecoration.underline),
                          ).opacity(.4),
                  ),
                  expanded: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                          future: lastTbFuture,
                          builder: (_, snp) {
                            var lastTb = snp.data;
                            return buildStartTime(
                                focusNode: timeFieldFocusNode,
                                maxTime: DateTime.now(),
                                minTime: lastTb?.endTime,
                                subWidget: Wrap(
                                  spacing: 4,
                                  children: _buildTimeQuickTool(),
                                ).focus(
                                  skipTraversal: true,
                                  canRequestFocus: false,
                                  descendantsAreFocusable: false,
                                  descendantsAreTraversable: false,
                                )).focus(
                                focusNode: focusNode,
                                onKey: (_, event) {
                                  if (event is RawKeyDownEvent) return KeyEventResult.ignored;
                                  if (event.logicalKey == LogicalKeyboardKey.minus) {
                                    setState(() {
                                      _subStartTime();
                                    });
                                    return KeyEventResult.handled;
                                  } else if (event.logicalKey == LogicalKeyboardKey.equal) {
                                    setState(() {
                                      _addStartTime();
                                    });
                                    return KeyEventResult.handled;
                                  }
                                  return KeyEventResult.ignored;
                                });
                          }),
                      gap12,
                      buildProgressDuration(
                        focusNode: durationFocusNode,
                      ),
                    ],
                  ),
                  collapsed: emptyWidget,
                )
                    .paddingSymmetric(
                      vertical: 12,
                    )
                    .material(
                      radius: 20,
                    ),
              ],
            ).center();
          }),
          // if (kDebugMode) Obx(() => Text("${tbRx.value}")),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFeedBackEditor(),
              gap4,
              Builder(builder: (context) {
                return TextField(
                  onChanged: (val) {
                    tbRx.justValue.updateFocus(context: val);
                  },
                  onSubmitted: (val) {
                    submit();
                  },
                  autofocus: PlatformUtils.isMobile ? false : true,
                  focusNode: contextFieldFocusNode,
                  controller: TextEditingController(text: tbRx.justValue.pomodoro.context),
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "记录你的想法//番茄钟、专注、思考、复盘".i18n,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: context.onBackground,
                      ),
                    ),
                  ),
                ).focus(onFocusChange: (focus) {
                  if (focus) {
                    Scrollable.ensureVisible(context);
                  }
                });
              }),
              gap12,
              Row(
                children: [
                  // OutlinedButton(
                  //         onPressed: () {
                  //           _addTime(addSeconds: 5 * 60);
                  //         },
                  //         child: Text("+5 min"))
                  //     .guideToolTip(FnActions.AddFiveMinutes.keySet),
                  // gap12,
                  // OutlinedButton(
                  //     onPressed: () {
                  //       _addTime(addSeconds: 10 * 60);
                  //     },
                  //     child: Text("+10 min")),
                  FnPopUpMenu(
                    configs: [
                      PopUpMenuConfig.withShortcur(
                        "放弃该专注//完成当前专注".i18n,
                        () async {
                          await $zenService.discardFocus(requestTb: $zenService.lastEndFocusTb);
                          close();
                        },
                        keySet: FnActions.DiscardCurrentFocus.keySet,
                        color: context.cs.error,
                      ),
                      PopUpMenuConfig.withShortcur(
                        "跳过复盘//总结、回顾".i18n,
                        () async {
                          close();
                        },
                        keySet: null,
                      ),
                    ],
                    child: Icon(FnIcons.moreV).opacity(.3).paddingSymmetric(horizontal: 8),
                  ),
                  Spacer(),
                  ElevatedButton(
                      focusNode: FocusNode(
                        skipTraversal: true,
                      ),
                      onPressed: () {
                        submit();
                      },
                      child: ShortcutTextWidget(
                        "提交".i18n,
                        keySet: FnKeys.cmdS,
                      )),
                ],
              ),
            ],
          ),
          Obx(() {
            if (_leftSeconds.value != null) {
              return Column(
                children: [
                  Text("${prettyDuration(_leftSeconds.value!.seconds)}"),
                  Text("倒计时结束自动提交".i18n),
                ],
              ).opacity(.3);
            }
            return emptyWidget;
          }),
          gap48,
        ],
      ).paddingSymmetric(
        horizontal: 12,
      ),
    );
  }

  List<Widget> _buildTimeQuickTool() {
    return [
      ActionChip(
        label: _buildShortLabel("-5 min", LogicalKeyboardKey.minus),
        onPressed: () {
          setState(() {
            _subStartTime();
          });
        },
      ),
      ActionChip(
        label: _buildShortLabel("+5 min", LogicalKeyboardKey.equal),
        onPressed: () {
          setState(() {
            _addStartTime();
          });
        },
      ),
    ];
  }

  void _addStartTime() async {
    // TimeBlock? lastTb = await lastTbFuture;
    var clamp = tbRx.justValue.startTime!.add(5.minutes).clamp(null, tbRx.justValue.endTime);
    tbRx.value = tbRx.justValue.updateTime(startTime: clamp).correctDuration();
    TimeBlockStore.find.save(tbRx.value);
  }

  void _subStartTime() async {
    // TimeBlock? lastTb = await lastTbFuture;
    var clamp = tbRx.justValue.startTime!.subtract(5.minutes).clamp(null, tbRx.justValue.endTime);
    tbRx.value = tbRx.justValue
        .updateTime(
          startTime: clamp,
        )
        .correctDuration();
    TimeBlockStore.find.save(tbRx.value);
  }

  Obx _buildFeedBackEditor() {
    return Obx(() {
      var feedback = feedbackEmojis[selectedEmotion.value];
      var feedbackEmojisTip = feedbackEmojisTips[feedback];
      return ListTile(
        title: feedbackEmojisTip == null ? null : Text(feedbackEmojisTip.random).opacity(.6),
        subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: () {
              var emoji = feedbackEmojis;
              return List.generate(emoji.length, (index) {
                return buildFeelIcon("${index + 1}", emoji.getNullable(index) ?? "", selected: selectedEmotion.value == index, onSelect: () {
                  selectedEmotion.value = index;
                }).tooltip("${FnModifyString.alt}${index + 1}");
              });
            }()),
      ).card();
    });
  }

  Widget _buildShortLabel(String text, LogicalKeyboardKey key) {
    return Builder(builder: (context) {
      var textStyle = context.defaultTextStyle;
      return RichText(
        text: TextSpan(
          style: textStyle,
          children: [
            TextSpan(
              text: text,
            ),
            if (PlatformUtils.isDesktop)
              TextSpan(
                  text: " [ " + key.toReadable() + " ]",
                  style: textStyle.copyWith(
                    color: context.primary,
                  )),
          ],
        ),
      );
    });
  }

  void _addTime({
    int addSeconds = 5 * 60,
  }) async {
    var promodo = _resultTb.pomodoro;
    if (promodo.leftSeconds != 0 && !kDebugMode) {
      return;
    }
    var resultTb = _resultTb;
    await $zenService.updateTimeBlock(
      resultTb.updateTime(
        endTime: DateTime.now().add(addSeconds.seconds),
      ),
    );
  }

  @override
  Rx<TimeBlock> get tbRx => _tbRx;
}

Widget buildFeelIcon(
  String key,
  String icon, {
  bool selected = false,
  double emojiSize = 35.0,
  required void Function() onSelect,
}) {
  return Builder(builder: (context) {
    return InkWell(
      // autofocus: selected ?? false,
      onTap: () {
        onSelect.call();
      },
      focusColor: Colors.transparent,
      child: Text(
        icon,
        style: TextStyle(
          fontSize: emojiSize,
        ),
      )
          .paddingOnly(
            left: 2,
          )
          .opacity(selected == true ? 1 : .4)
          .container(
            color: selected == true ? context.onBackground.withOpacity(.1) : Colors.transparent,
            padding: EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 2,
            ),
            borderRadius: BorderRadius.circular(
              8,
            ),
          )
      /*  .sizedBox(
              height: 48,
              width: 48,
            )*/
      ,
    );
  });
}
