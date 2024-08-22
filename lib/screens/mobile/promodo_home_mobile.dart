import 'dart:async';
import 'dart:math';

import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide NumDurationExtensions;
import 'package:flutter_pasteboard/component/account/account_future_widget.dart';
import 'package:flutter_pasteboard/component/audio/audio_mix_widget.dart';
import 'package:flutter_pasteboard/component/fn_getx/fn_obx_widget.dart';
import 'package:flutter_pasteboard/component/fn_popMenu.dart';
import 'package:flutter_pasteboard/component/setting/setting_page_share.dart';
import 'package:flutter_pasteboard/component/tag/tag_widget.dart';
import 'package:flutter_pasteboard/component/time_picker/fn_time_picker.dart';
import 'package:flutter_pasteboard/component/timer/focus_countdown_widget.dart';
import 'package:flutter_pasteboard/component/timer/pomodoro_end_widget.dart';
import 'package:flutter_pasteboard/component/timer/pomodoro_timer_extension.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/feedback_utils.dart';
import 'package:flutter_pasteboard/misc/fn_bottomsheet.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/fngetutils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/guide/guide_data.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/misc/log/logger_view.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/screens/DebugPage.dart';
import 'package:flutter_pasteboard/screens/mobile/controller/pomodoro_home_controller.dart';
import 'package:flutter_pasteboard/screens/mobile/timeblock/timeblock_edit_mobile.dart';
import 'package:flutter_pasteboard/screens/mobile/timeblock/timeblock_list_view_mobile.dart';
import 'package:flutter_pasteboard/screens/stats_page_share.dart';
import 'package:flutter_pasteboard/service/account/account_service.dart';
import 'package:flutter_pasteboard/service/fn_audioservice.dart';
import 'package:flutter_pasteboard/service/sync/sync_function.dart';
import 'package:flutter_pasteboard/service/sync/sync_helper.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';
import 'package:flutter_pasteboard/service/time_block_store.dart';
import 'package:flutter_pasteboard/service/time_rule_misc.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

class PomodoroHomeMobile extends StatefulWidget {
  const PomodoroHomeMobile({super.key});

  @override
  State<PomodoroHomeMobile> createState() => _PomodoroHomeMobileState();
}

class _PomodoroHomeMobileState extends State<PomodoroHomeMobile> with ITimeBlockOnEdit, ITimeBlockOnFocus, ITimeBlockOnRest {
  PomodoroHomeController controller = Get.find();
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  late final StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    TimeBlockStore.find;
    TagStore.find;
    FnAudioService.instance;
    _sub = initTb();
  }

  @override
  void dispose() {
    super.dispose();
    _sub.cancel();
  } // 处理下

  Rx<PomodoroState> get _state => $zenService.stateRx;
  final double topHeight = 88.0;

  void _onItemTapped(int index) {
    setState(() {
      controller.selectedIndex = index;
    });
  }

  late final List<Widget> _widgetOptions = <Widget>[
    _buildPomodoroBody(),
    TimeBlockListViewMobile(),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PomodoroHomeController>(
      init: controller,
      builder: (controller) {
        var sf = Scaffold(
          appBar: _buildappBar(context),
          bottomNavigationBar: BottomNavigationBar(
            elevation: 0,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.schedule_sharp),
                label: 'Home'.i18n,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_note),
                label: 'TimeLine'.i18n,
              ),
            ],
            selectedFontSize: 12,
            unselectedFontSize: 12,
            currentIndex: controller.selectedIndex,
            selectedItemColor: context.primary,
            onTap: _onItemTapped,
          ),
          resizeToAvoidBottomInset: false,
          key: _key,
          body: Center(
            child: _widgetOptions.getNullable(controller.selectedIndex) ?? Text(controller.selectedIndex.toString()),
          ) /*.gradient(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // stops: [0.7, 0.2, 0.1],
            colors: [
              context.background,
              context.background.blend(Colors.yellow, 20),
              context.background.blend(Colors.yellow, 40),
            ],
          ))*/
          ,
          drawer: _buildDrawer(),
        ).safeArea().container(color: context.background).swipeDetector(onSwipeRight: (_) {
          _key.currentState?.openDrawer();
        });
        var vm = controller.timeBlockModel.value;
        if (vm != null) {
          return DefaultTabController(
            length: vm.length,
            child: Builder(builder: (context) {
              return sf.onLifeCycle(onInit: () {
                var maybeOf = DefaultTabController.maybeOf(context);
                maybeOf?.addListener(() {
                  vm.initIdx = maybeOf.index;
                });
              });
            }),
            initialIndex: vm.initIdx,
          );
        } else {
          return sf;
        }
      },
    );
  }

  PreferredSize _buildappBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(context.appbarTheme.toolbarHeight ?? 86),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _key.currentState?.openDrawer();
            },
          ),
          Obx(() {
            var vm = controller.timeBlockModel.value;
            if (vm == null) return emptyWidget;
            return TabBar(
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: context.focusColor,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              splashBorderRadius: BorderRadius.circular(32),
              tabs: vm.tabs,
            );
          }).expand(),
          Obx(() {
            if (controller.selectedIndex != 0) return emptyWidget;
            var instance = SyncMangerController.instance;
            var allSuccess = instance.allSuccess;
            if (allSuccess) return emptyWidget;
            var icon = Icon(instance.computeIconData()).opacity(.3).paddingSymmetric(horizontal: 8);
            return icon;
          }),
          // _buildTitle().expand(),
          debugWidget(() => FnPopUpMenu(
                configs: [
                  ...DebugPopUpConfig.mobilePopConfgs(context),
                  ...DebugPopUpConfig.deskTopPopConfgs(context),
                ],
                child: Icon(Icons.developer_mode_outlined),
              )),
          Obx(() {
            var configs = [
              PopUpMenuConfig.textBtn("应用内反馈".i18n, () {
                FeedbackUtils.instance.show(context);
              }),
              PopUpMenuConfig.textBtn(
                "自定义背景音".i18n,
                () {
                  showAuioMixWidget();
                },
              ),
            ];
            return GuidePopWrapper(configs: configs);
          }),
        ],
      ).safeArea(),
    );
  }

  Widget _buildRestClock() {
    return Obx(() {
      var curTimeBlock = $zenService.curTimeBlock;
      late int progressSconds;
      late int curMaxTime;
      if (curTimeBlock.isRest) {
        var rest = $zenService.curTimeBlock.rest;
        progressSconds = rest.progressSeconds;
        curMaxTime = rest.durationSeconds;
      } else {
        progressSconds = 0;
        curMaxTime = TimeRuleController.find.ensureRest(next: false).minus * 60;
      }

      var value = (progressSconds / (max(curMaxTime, 3)));
      return CircleTimerWrapper(
        strokeWidth: 10,
        child: buildRestCountDownTimer(context),
        percent: value,
      );
    });
  }

  Widget _buildPomodoroBody() {
    return FnObxValue(() {
      var state = _state.justValue;
      if (state == PomodoroState.FocusFeedBack && $zenService.lastEndFocusTb != null) {
        return PomodoroEndWidget(tb: $zenService.lastEndFocusTb!);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          gap12,
          debugWidget(() => Text("${tbRxAdaptive.value.durationSeconds / 60} min")),
          (state.isRest ? _buildRestClock() : _buildClockBody(context, state)).expand(),
          FnObxValue(
              () => SizedBox(
                    height: 128,
                    child: (state.isRest
                        ? emptyWidget
                        : _buildTaskTitle(context).center().inkWell(onTap: () {
                            _requestUpdateTb(
                              mode: TimeBlockEditorMobileMode.edit,
                            );
                          })),
                  ),
              [_state]),
          Obx(() {
            var state = _state.value;
            if (state.isFocus) {
              return buildBtnOnFocus(context);
            } else if (state == PomodoroState.Edit || state.isFeedback) {
              return buildBtnOnEdit(context);
            } else if (state.isRest) {
              return buildBtnOnRest(context);
            } else {
              return Text("${state}");
            }
          }),
          Obx(() {
            return $zenService.isFocus ? _buildFocusNote() : emptyWidget;
          }),
          gap24,
          /*rest*/
          // if (state.isDoing) buildDesc(),
        ],
      );
    }, [
      _state,
    ]);
  }

  void _requestUpdateTb({
    required TimeBlockEditorMobileMode mode,
    TimeBlock? tb,
  }) async {
    if (tb != null) {
      fnassert(() => tb.uuid == tbRxAdaptive.justValue.uuid);
    }
    await FnBottomSheet.bottomSheet(TimeBlockEditorMobile(
      onCancel: () => Get.back(),
      mode: mode,
      onSubmit: (tb) {
        tbRxAdaptive.value = tb;
        DebugUtils.log("promodo_home_mobile:229: ${tb} \n${StackTrace.current}");
        Get.back();
      },
      tb: tbRxAdaptive.justValue,
    ));
    setState(() {});
  }

  Widget _buildFocusNote() {
    return SizedBox(
      height: 40,
      child: Text(
        "记录专注笔记".i18n,
        style: context.bodyMedium,
      ).opacity(.3).center(),
    ).inkWell(onTap: () {
      _requestUpdateTb(
        mode: TimeBlockEditorMobileMode.editContext,
      );
    });
  }

  Widget _buildElevedBtn(String text, void Function() onTap) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // 圆角的大小
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: context.titleMedium.copyWith(color: context.cs.onPrimary),
        ).paddingSymmetric(
          vertical: 8,
        )).expand();
  }

  Widget _buildPrimaryBtn(IconData data, void Function() onTap) {
    return Ink(
      decoration: ShapeDecoration(
        color: context.cs.primaryContainer,
        shape: CircleBorder(),
      ),
      child: IconButton(
        padding: EdgeInsets.all(16),
        iconSize: 32,
        icon: Icon(data),
        color: context.cs.onPrimaryContainer.withOpacity(.4),
        onPressed: onTap,
      ),
    );
  }

  Widget buildDesc() {
    return FnObxValue(() {
      if (_state.justValue == PomodoroState.Edit) {
        return emptyWidget;
      }
      var curTb = $zenService.curTimeBlock;
      if (curTb.isRest) {
        return Text("休息中...".i18n);
      }
      var promodo = curTb.pomodoro;
      var res = """${promodo.context?.toString() ?? ""}""";
      return TextField(
        controller: TextEditingController(text: res),
        onChanged: (value) => $zenService.updateCurPromodo((p0) => p0.copyWith(context: value)),
        cursorHeight: 16,
        autofocus: PlatformUtils.isDesktop,
        minLines: 1,
        maxLines: 3,
        decoration: InputDecoration(
          fillColor: Colors.transparent,
          hintStyle: context.bodyMedium.copyWith(
            color: context.bodyMedium.color?.withOpacity(.3),
          ),
          hintText: "记录你的想法、领悟或困惑".i18n,
          border: InputBorder.none,
        ),
      ).paddingSymmetric(
        horizontal: 12,
      );
    }, [
      _state,
    ]);
  }

  RxBool _showOverlay = RxBool(false);

  void showEditTime(TimeBlock tb) {
    _showOverlay.value = true;
  }

  Widget _buildClockBody(BuildContext context, PomodoroState state) {
    fnassert(() => !state.isFeedback, [state, $zenService.lastEndFocusTb]);
    var style = context.titleLarge
        .copyWith(
          fontWeight: FontWeight.w900,
        )
        .withBigger(20);
    var curTimeBlock = tbRxAdaptive;
    fnassert(() => curTimeBlock.justValue.isFocus, curTimeBlock);
    return LayoutBuilder(builder: (context, c) {
      var size = min(c.maxWidth, c.maxHeight);
      void _update(TimeBlock tb) {
        _requestUpdateTb(
          tb: tb,
          mode: $zenService.isFocus ? TimeBlockEditorMobileMode.editTimeOnPlaying : TimeBlockEditorMobileMode.edit,
        );
      }

      if ($zenService.isFocus) {
        return Obx(() {
          return CircleTimerWrapper(
            key: ValueKey(curTimeBlock.value),
            strokeWidth: 20,
            percent: 1 - $zenService.left.inSeconds / $zenService.duration.inSeconds,
            child: FocusCountDownWidget(
              onTap: (tb) => _update(tb),
              timeStyle: style,
              tbRx: curTimeBlock,
            ),
          );
        });
      }
      return Obx(() {
        var duration = curTimeBlock.value.pomodoro.durationSeconds.seconds;
        if (_timerKey.currentContext != null) {
          _timerKey.currentState?.updateTime(duration);
        }
        return FnTimePicker(
          key: _timerKey,
          // onStartChange: (DateTime starTime) {
          //   curTimeBlock.value = curTimeBlock.justValue.updatePromodo(
          //       startTime: starTime,
          //       mapper: (pomodo) {
          //         return pomodo.copyWith(
          //           progressSeconds: DateTime.now().difference(starTime).inSeconds - pomodo.pauseSeconds,
          //         );
          //       });
          // },
          onDurationChange: (Duration duration) {
            curTimeBlock.value = curTimeBlock.justValue.updatePromodo(mapper: (pomodo) {
              return pomodo.copyWith(
                durationSeconds: max((duration.inSeconds / 60).toInt() * 60, 60),
              );
            });
          },
          duration: duration,
          child: FocusCountDownWidget(
            canShowTimeBtn: false,
            onTap: (tb) => _update(tb),
            timeStyle: style,
            tbRx: curTimeBlock,
          ),
        );
      }).boxConstraints(maxHeight: size, maxWidth: size);
    });
  }

  final focusNode = FocusNode();
  final GlobalKey<FnTimePickerState> _timerKey = GlobalKey();

  Widget _buildTaskTitle(BuildContext context) {
    return Obx(() {
      var rx = tbRxAdaptive;
      var tb = rx.value;
      if (tb.isRest) return emptyWidget;
      var promodo = tb.pomodoro;
      var title = promodo.titleWithoutTag?.trim().takeIf((it) => it.isNotEmpty);
      var data = title ?? "没有指定任务".i18n;
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(data).paddingSymmetric(vertical: 4).opacity(title == null ? .4 : 1),
          promodo.tags.isEmpty
              ? Text(
                  "没有指定标签".i18n,
                  style: context.bodySmall,
                ).opacity(.3)
              : Builder(builder: (context) {
                  return Wrap(
                    spacing: 4,
                    children: promodo.tags.mapToList((e) {
                      var tag = TagStore.find.id2tag[e];
                      if (tag == null) return kDebugMode ? Text("找不到对应的标签".i18n) : emptyWidget;
                      return Chip(
                        label: Text(tag.value),
                        backgroundColor: tag.color?.withOpacity(.3),
                      );
                    }),
                  );
                }),
        ],
      );
    });
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacer(),
          if (kAnyDebug)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AccountFuture(builder: (find) {
                  return _buildDrawerBtn(
                    selected: true,
                    onPressed: () {
                      if (find.isLogin) {
                        find.logout();
                      }
                      routes.offSignUp();
                    },
                    child: Text("Account"),
                    icon: Icon(Icons.account_circle_outlined),
                  );
                }),
                _buildDrawerBtn(
                  selected: true,
                  onPressed: () {
                    routes.to(() => DebugPage());
                  },
                  child: Text("DEBUG"),
                  icon: Icon(Icons.logo_dev),
                ),
                _buildDrawerBtn(
                  selected: true,
                  onPressed: () {
                    routes.to(() => $LoggerView());
                  },
                  child: Text("LOG"),
                  icon: Icon(Icons.note_alt_outlined),
                ),
              ],
            ).container(color: context.cs.primaryContainer),
          gap24,
          AccountFuture(builder: (find) {
            return FutureBuilder(
                future: find.loginSuccessFuture,
                builder: (_, snap) {
                  if (snap.data != true) {
                    return _buildDrawerBtn(
                      selected: true,
                      onPressed: () {
                        find.logout();
                        routes.offSignUp();
                      },
                      child: Text("Login".i18n),
                      icon: Icon(FnIcons.login),
                    );
                  }
                  return emptyWidget;
                });
          }),
          _buildDrawerBtn(
            selected: true,
            onPressed: () {
              FeedbackUtils.instance.show(context);
            },
            child: Text("FeedBack".i18n),
            icon: Icon(FnIcons.feedback),
          ),
          Divider(),
          Obx(() {
            return _buildDrawerBtn(
              onPressed: () {
                batchSync();
              },
              child: Text("Sync".i18n),
              icon: Icon(SyncMangerController.instance.computeIconData()),
            );
          }),
          _buildDrawerBtn(
            onPressed: () {
              routes.to(() => TagPageMobile());
            },
            child: Text("Tag".i18n),
            icon: Icon(Icons.tag),
          ),
          _buildDrawerBtn(
            onPressed: () {
              routes.to(() => StatsPageAdaptive());
            },
            child: Text("Stats//统计分析".i18n),
            icon: Icon(Icons.query_stats),
          ),
          _buildDrawerBtn(
            onPressed: () {
              routes.to(() => SettingPage());
            },
            child: Text("Setting".i18n),
            icon: Icon(Icons.settings_outlined),
          ),
          gap24,
        ],
      ),
    );
  }

  Widget _buildDrawerBtn({
    required void Function() onPressed,
    required Widget child,
    Widget? icon,
    bool selected = false,
  }) {
    return ListTile(
      selected: selected,
      leading: icon,
      title: child,
      onTap: onPressed,
    );
  }

  final Rx<TimeBlock> _tbRx = Get.touch(() => Rx<TimeBlock>(TimeBlock.emptyFocus()), tag: "edit_tb");

  Rx<TimeBlock> get tbRxAdaptive => $zenService.isFocus ? $zenService.$curTimeBlock : _tbRx;

  @override
  Rx<TimeBlock> get tbRx => _tbRx;
}

class GuidePopWrapper extends StatelessWidget {
  const GuidePopWrapper({
    super.key,
    required this.configs,
  });

  final List<PopUpMenuConfig> configs;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: GuideService.instance.getGuideList(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData) {
            var hasData = !snapshot.data.isEmptyOrNull;
            // DebugUtils.log("promodo_home_mobile:145 :${snapshot.data}\n${StackTrace.current}");
            var fnPopUpMenu = FnPopUpMenu(
              configs: [
                if (hasData)
                  PopUpMenuConfig(
                      Badge(
                        label: Text("1"),
                        child: Text("删除引导数据".i18n),
                      ), () async {
                    await GuideService.instance.deleteGuide();
                    Get.rootController.update();
                  }),
                PopUpMenuConfig.diver(),
                ...configs,
              ],
              child: Icon(Icons.more_vert_rounded).paddingAll(8),
            );
            if (hasData) {
              return Badge(
                label: Text("1"),
                alignment: Alignment.topLeft,
                child: fnPopUpMenu,
              );
            }
            return fnPopUpMenu;
          } else if (snapshot.hasError) {
            return Icon(Icons.error_outline);
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
