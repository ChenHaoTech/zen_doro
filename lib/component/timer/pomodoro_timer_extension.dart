import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/component/fn_popMenu.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/component/timer/hollow_circle_widget.dart';
import 'package:flutter_pasteboard/component/timer/rest_countdown_widget.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/fn_dialog.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/model/misc.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/screens/desktop/dasboard/_share.dart';
import 'package:flutter_pasteboard/service/fn_audioservice.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:flutter_pasteboard/service/time_rule_misc.dart';
import 'package:flutter_pasteboard/service/undo_controller.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

class TextInputFormatterWithAutoClear extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 2) {
      return TextEditingValue(
        text: newValue.text[newValue.text.length - 1],
        selection: TextSelection.collapsed(offset: 1),
      );
    }
    return newValue;
  }
}

abstract mixin class ITimeBlockOnRest {
  final Rx<RestType> restType = Get.touch(() => Rx(RestType.COUNT_DOWN), permanent: true);
  late TimeBlock _fallbackRestTb = TimeBlock.emptyCountDownRest().switchRestType(restType.justValue);

  bool get isRest => $zenService.curTimeBlock.isRest;

  Widget buildRestCountDownTimer(BuildContext context) {
    var style = context.bodyLarge.copyWith(
      fontSize: 46.0,
    );
    return RestCountDownWidget(
      timeStyle: style,
      tbRx: $zenService.$curTimeBlock,
    );
  }

  void startRest() async {
    if ($zenService.state == PomodoroState.Rest) return;
    await $zenService.updateTimeBlock(_fallbackRestTb.switchRestType(restType.justValue));
    $zenService.startRest();
  }

  void discard() async {
    $zenService.discardRest();
  }

  void stopRest() async {
    if (!isRest) return;
    await $zenService.stopRest();
    if (SettingService.instance.autoFocus.value) {
      var unit = TimeRuleController.find.ensureFocus(next: true);
      $zenService.startFocus(unit.buildTb().whenFocus()!);
    }
  }

  void resetRest() {
    $zenService.resetRest();
  }

  Widget buildBtnOnRest(BuildContext context) {
    return Obx(
      () {
        if (!$zenService.isRest) return emptyWidget;
        var curTimeBlock = $zenService.curTimeBlock;
        var tooSmall = curTimeBlock.progressSeconds < SettingService.instance.smallestLifeOfRest.value * 60;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FnBtn(
              onTap: () => resetRest(),
              data: FnIcons.refresh,
              iconColor: context.restColor,
              containerColor: context.restContainerColor,
              keySet: FnActions.ResetRest.keySet,
            ),
            if (!$zenService.isRest)
              FnBtn(
                onTap: () => startRest(),
                data: FnIcons.start,
                iconColor: context.restColor,
                containerColor: context.restContainerColor,
                keySet: FnActions.StartRest.keySet,
              ),
            if (tooSmall)
              FnBtn(
                data: FnIcons.close,
                onTap: () => discard(),
                iconColor: context.pomodoroColor,
                containerColor: context.pomodoroContainerColor,
                keySet: FnActions.DiscardCurrentRest.keySet,
              ),
            if (!tooSmall)
              FnPopUpMenu(
                configs: [
                  PopUpMenuConfig.withShortcur(
                    "完成休息//结束休息".i18n,
                    () {
                      stopRest();
                    },
                    keySet: FnActions.StopRest.keySet,
                  ),
                  PopUpMenuConfig.withShortcur(
                    "放弃休息//结束休息".i18n,
                    () {
                      discard();
                    },
                    keySet: FnActions.DiscardCurrentRest.keySet,
                    color: context.cs.error,
                  ),
                ],
                child: FnBtn(
                  data: FnIcons.skip,
                  iconColor: context.pomodoroColor,
                  containerColor: context.pomodoroContainerColor,
                  keySet: FnActions.DiscardCurrentRest.keySet,
                ),
              ),
          ],
        );
      },
    );
  }
}

abstract mixin class ITimeBlockOnEdit {
  Rx<TimeBlock> get tbRx;
}

extension TimeBlockActionExt on ITimeBlockOnEdit {
  Future<dynamic> start() async {
    // 手动开始的, 必须没有starttime
    if (tbRx.justValue.startTime != null) {
      tbRx.value = tbRx.justValue.updateTime(startTime: FnDateUtils.findMin([DateTime.now(), tbRx.justValue.startTime]));
    }
    await $zenService.startFocus(tbRx.justValue);
  }

  void startRest() {
    var restUnit = TimeRuleController.find.ensureRest(next: true);
    //todo smarl rest
    $zenService.startRest(restUnit.mustRest());
  }

  StreamSubscription initTb({
    Function(TimeBlock)? tbChange,
  }) {
    var unit = TimeRuleController.find.ensureFocus(next: false);
    tbRx.value = unit.mustFocus();
    tbChange?.call(tbRx.value);
    return $zenService.stateRx.listen((state) {
      if (state != PomodoroState.Edit) {
        //todo 任务列表 下一个番茄
        var nextPomodoroUnit = TimeRuleController.find.ensureFocus(next: false);
        tbRx.value = nextPomodoroUnit.buildTb().whenFocus()!;
        tbChange?.call(tbRx.value);
      }
    });
  }

  Widget buildBtnOnEdit(BuildContext context) {
    if (!context.isMobile) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FnBtn(
            onTap: () => start(),
            data: FnIcons.start,
            iconColor: context.primary,
            containerColor: context.cs.primaryContainer,
            keySet: FnActions.StartFocus.keySet,
          ),
          FnBtn(
            onTap: () {
              startRest();
            },
            iconSize: 28,
            data: FnIcons.rest,
            iconColor: context.restColor,
            containerColor: context.restContainerColor,
            keySet: FnActions.StartRest.keySet,
          ),
        ],
      );
    }
    return Column(
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            start();
          },
          style: ElevatedButton.styleFrom(
              textStyle: context.titleMedium,
              padding: EdgeInsets.symmetric(
                horizontal: 48,
                vertical: 16,
              )),
          child: Text("开始专注".i18n),
        ),
        TextButton(
          onPressed: () {
            startRest();
          },
          child: Text(
            "开始休息".i18n,
          ).opacity(.4),
        )
      ],
    );
  }
}

class NextActionPopUpMenu extends StatelessWidget with ITimeBlockOnFocus {
  final bool tooSmall;
  final IconData iconData;
  final Color iconColor;
  final Color containerColor;

  const NextActionPopUpMenu({
    Key? key,
    required this.tooSmall,
    required this.iconData,
    required this.iconColor,
    required this.containerColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var endText = "完成专注".i18n;
    var dircardText = "放弃专注".i18n;
    if (tooSmall) {
      return FnBtn(
        onTap: () => $zenService.discardFocus(),
        data: iconData,
        iconColor: iconColor,
        keySet: FnActions.DiscardCurrentFocus.keySet,
        containerColor: containerColor,
      );
    }
    return FnPopUpMenu(
      tooltip: endText + "${FnActions.DiscardCurrentRest.keySet?.toReadable()}",
      configs: [
        PopUpMenuConfig.withShortcur(
          "开始休息".i18n,
          () async {
            await $zenService.stopFocus(needfeedback: false);
            await $zenService.startRest(TimeRuleController.find.getCurPomodoroUnit().buildTb().whenRest() ?? TimeBlock.emptyCountDownRest());
          },
          keySet: FnActions.StartRest.keySet,
          color: context.restColor,
        ),
        PopUpMenuConfig.withShortcur(
          "下一个专注".i18n,
          () => nextFocus(),
          keySet: FnActions.NextTask.keySet,
        ),
        PopUpMenuConfig.diver(),
        PopUpMenuConfig.withShortcur(endText, () {
          $zenService.stopFocus();
        }, keySet: FnActions.StopFocus.keySet),
        PopUpMenuConfig.withShortcur(
          dircardText,
          () async {
            $zenService.discardFocus();
          },
          color: context.cs.error,
          keySet: FnActions.DiscardCurrentFocus.keySet,
        ),
      ],
      child: FnBtn(
        data: iconData,
        iconColor: iconColor,
        containerColor: containerColor,
      ),
    );
  }
}

abstract mixin class ITimeBlockOnFocus {
  Future nextFocus() async {
    var tb = $zenService.curTimeBlock;
    var leftSeconds = tb.leftSeconds;
    var tag = tb.tags.firstOrNull;
    await $zenService.stopFocus(needfeedback: false);
    var unit = TimeRuleController.find.ensureFocus(next: true);
    //todo 处理下一个任务
    var nextTb = unit.buildTb().updateFocus(tag: tag);
    if (leftSeconds > 0) {
      var originDuration = nextTb.durationSeconds;
      nextTb = nextTb.updateFocus(durationSeconds: leftSeconds);
      FnUndoController.find.showUndo(
          promopt: "剩余的时间自动添加到当前专注中",
          onUndo: () {
            $zenService.startFocus(nextTb.updateFocus(durationSeconds: originDuration));
          });
    }
    await $zenService.startFocus(nextTb);
  }

  bool get tooSmall {
    var block = $zenService.curTimeBlock;
    if (block.isFocus) return block.progressSeconds < SettingService.instance.smallestLifeOfTask.value * 60;
    return false;
  }

  Widget buildBtnOnFocus(BuildContext context) {
    var iconBtn = context.cs.primary;
    var primaryContainer = context.cs.primaryContainer;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Obx(() {
          var isMute = FnAudioService.instance.isMute;
          late IconData data;
          if (isMute) {
            data = Icons.volume_off_rounded;
          } else {
            data = Icons.volume_up_rounded;
          }
          return FnBtn(
            onTap: () => FnAudioService.instance.toggleMute(),
            data: data,
            iconColor: iconBtn,
            containerColor: primaryContainer,
          ).tooltip("cmd+/cmd-");
        }),
        Obx(() {
          var state = $zenService.state;
          late IconData data;
          if (state == PomodoroState.FocusPause) {
            data = Icons.play_arrow_outlined;
          } else {
            data = Icons.pause;
          }
          return FnBtn(
            onTap: () => togglePause(),
            data: data,
            iconColor: iconBtn,
            containerColor: primaryContainer,
            keySet: FnActions.ToggleFocus.keySet,
          );
        }),
        Obx(() {
          return NextActionPopUpMenu(
            tooSmall: tooSmall,
            iconData: tooSmall ? FnIcons.discard : FnIcons.skip,
            iconColor: iconBtn,
            containerColor: primaryContainer,
          );
        }),
      ],
    ).inkWell(
      onTap: () => toggleOnFocus($zenService.curTimeBlock.whenFocus()),
    );
  }

  void toggleOnFocus(TimeBlock? tb) {
    if ($zenService.isFocus) {
      togglePause();
    } else {
      $zenService.startFocus(tb);
    }
  }

  void togglePause() {
    if (FnDialog.isShow) return;
    var state = $zenService.state;
    if (state.isFocus) {
      if (state.isPause) {
        $zenService.resume();
      } else {
        $zenService.pause();
      }
    } else {
      this.log.e("不应该执行到这里:${state}");
    }
  }
}

class CircleTimerWrapper extends StatelessWidget {
  const CircleTimerWrapper({
    super.key,
    required this.strokeWidth,
    required this.child,
    required this.percent,
  });

  final double strokeWidth;
  final double percent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints contraints) {
      var minSizeFromConstraint = min(contraints.maxWidth, contraints.maxHeight);
      if (minSizeFromConstraint.isInfinite) return Text("Infinite contraints: ${contraints}");
      // DebugUtils.log("_promodo_play:222 :${minSizeFromConstraint}, ${contraints}\n${StackTrace.current}");
      if (minSizeFromConstraint < 230) return child.center();
      return Stack(
        clipBehavior: Clip.none,
        children: [
          LayoutBuilder(builder: (context, BoxConstraints contraints) {
            Widget indicator = HollowCircleWidget(
              percent: percent,
              strokeWidth: strokeWidth,
            );
            if ($zenService.stateRx.value.isPause) {
              indicator = indicator.opacity(.4);
            }
            return indicator.sizedBox(
              width: minSizeFromConstraint,
              height: minSizeFromConstraint,
            );
          }).hero("timer").paddingAll(8),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: child.center().container(
                // color: Colors.red,
                ),
          ),
        ],
      ).sizedBox(
        width: minSizeFromConstraint,
        height: minSizeFromConstraint,
      );
    });
  }
}

mixin FastUpdateTime {
  Rx<TimeBlock> get tbRx;

  void addDuration(int minus) {
    var startTime = tbRx.justValue.startTime;
    var endTime = tbRx.justValue.endTime;
    if (startTime == null || endTime?.isBefore(DateTime.now()) != true) {
      var seconds = tbRx.justValue.durationSeconds + minus * 60;
      $zenService.updateTimeBlock(tbRx.justValue.updateTime(durationSeconds: seconds).correctEndTime());
    } else {
      fnassert(() => endTime!.isBefore(DateTime.now()));
      var inSeconds2 = DateTime.now().add(minus.minutes).difference(startTime).inSeconds;
      $zenService.updateTimeBlock(tbRx.justValue.updateTime(durationSeconds: inSeconds2).correctEndTime());
    }
  }

  void subDuration(int minus) {
    var seconds = tbRx.justValue.durationSeconds - minus * 60;
    seconds = max(seconds, 0);
    $zenService.updateTimeBlock(tbRx.justValue.updateTime(
      durationSeconds: seconds,
    ));
  }
}
