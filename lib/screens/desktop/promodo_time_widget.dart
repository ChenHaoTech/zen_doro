import 'dart:async';

import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/audio/audio_mix_widget.dart';
import 'package:flutter_pasteboard/component/fn_getx/fn_obx_widget.dart';
import 'package:flutter_pasteboard/component/fn_popMenu.dart';
import 'package:flutter_pasteboard/component/short_cut/ShortProvider.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/component/time_block_widget/time_block_list_widget.dart';
import 'package:flutter_pasteboard/component/timer/pomodoro_end_widget.dart';
import 'package:flutter_pasteboard/component/week_start_from.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/screens/DebugPage.dart';
import 'package:flutter_pasteboard/screens/desktop/dasboard/_pomodoro_rest.dart';
import 'package:flutter_pasteboard/screens/desktop/dasboard/_promodo_eidt.dart';
import 'package:flutter_pasteboard/screens/desktop/dasboard/_promodo_play.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/fn_week_view.dart';
import 'package:flutter_pasteboard/screens/mobile/promodo_home_mobile.dart';
import 'package:flutter_pasteboard/service/fn_audioservice.dart';
import 'package:flutter_pasteboard/service/sync/sync_helper.dart';
import 'package:flutter_pasteboard/service/time_block_store.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

class PromodoTimeWidgetDesktop extends StatefulWidget {
  const PromodoTimeWidgetDesktop({super.key});

  @override
  State<PromodoTimeWidgetDesktop> createState() => _PromodoTimeWidgetDesktopState();
}

class _PromodoTimeWidgetDesktopState extends State<PromodoTimeWidgetDesktop> {
  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      backgroundColor: context.primary.withOpacity(.05),
      body: Column(
        children: [
          _buildTopStatsBar(context),
          Row(
            children: [
              _buildPromodo(context).expand(flex: 3),
              gap12,
              PormodoDayView().expand(flex: 2),
            ],
          ).expand(),
        ],
      ),
    ).portal();
    return ShortcutRooter(child: scaffold);
  }

  Row _buildTopStatsBar(BuildContext context) {
    return Row(
      children: [
        debugWidget(() {
          var syncState = SyncMangerController.instance.syncHelpers.mapToList((e) => "[${e.kvType.name},${e.state.value.name}]").join(",");
          return Text(syncState);
        }).expand(),
        Obx(
          () {
            var state = $zenService.state;
            if (state.isFocus) return emptyWidget;
            return Text(
              FnDateUtils.formatDuration_hh_mm(
                FnDateUtils.now.value.difference(
                  TimeBlockStore.find.lastTimeStamp.value,
                ),
              ),
              style: context.bodyMedium.copyWith(
                color: context.primary,
              ),
            ).tooltip(state == PomodoroState.Rest ? "已经休息".i18n : "距离上次番茄".i18n);
          },
        ).opacity(.4),
        gap12,
        debugWidget(() => FnPopUpMenu(child: Icon(Icons.auto_fix_high), configs: [
              ...DebugPopUpConfig.deskTopPopConfgs(context),
              ...DebugPopUpConfig.mobilePopConfgs(context),
            ])),
        Obx(() {
          return GuidePopWrapper(configs: [
            // PopUpMenuConfig.withShortcur("小窗模式".i18n, keySet: FnActions.ToggleMiniWindow.keySet, () async {
            //   await $windowService.setSize(promodoSize);
            //   routes.off(() => PromodoEdit());
            // }),
            // PopUpMenuConfig.withShortcur("结束当前 session".i18n, keySet: FnActions.ResetSession.keySet, () {
            //   TimeRuleController.instance.reset();
            // }),
            PopUpMenuConfig.withShortcur(
              "自定义背景音".i18n,
              () {
                showAuioMixWidget();
              },
              keySet: FnActions.OpenMixAdjustmentWindow.keySet,
            ),
            PopUpMenuConfig.withShortcur(FnAudioService.instance.isMute ? "UnMute".i18n : "Mute".i18n, keySet: FnActions.ToggleMute.keySet, () {
              FnAudioService.instance.toggleMute();
            }),
          ]);
        }),
      ],
    );
  }

  Widget _buildPromodo(BuildContext context) {
    var child = FnObxValue(() {
      var state = $zenService.stateRx.value;
      if (state.isFeedback && $zenService.lastEndFocusTb != null) {
        return PomodoroEndWidget(
          tb: $zenService.lastEndFocusTb!,
        );
      } else if (state.isFocus) {
        return PomodoroPlayDashboardDesktop();
      } else if (state.isRest) {
        return PomodoroRestDashboardDesktop();
      } else {
        return PomodoroEditDashboardDesktop();
      }
    }, [$zenService.stateRx]);
    return child.center();
  }
}

class PormodoDayView extends StatefulWidget {
  const PormodoDayView({super.key});

  @override
  State<PormodoDayView> createState() => _PormodoDayViewState();
}

class _PormodoDayViewState extends State<PormodoDayView> with StateDisposeMixin {
  late final StreamSubscription _sub;
  late DateTime _startTime;
  late DateTime _endTime;

  @override
  void dispose() {
    super.dispose();
    _sub.cancel();
  }

  @override
  void initState() {
    super.initState();
    TimeBlockStore.find;
    _sub = FnDateUtils.nowYmd.listen((p0) {
      _init(p0);
    });
    _init(FnDateUtils.nowYmd.justValue);
  }

  void _init(DateTime p0) {
    _startTime = p0.onlyYmd();
    _endTime = p0.onlyYmd().add(1.days);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HorizontalWeekCalendar(
          key: UniqueKey(),
          showTopNavbar: false,
          onDateChange: (date) {
            setState(() {
              _startTime = date;
              _endTime = _startTime.add(1.days);
            });
          },
          minDate: DateTime.now().subtract(60.days),
          initialDate: _startTime.onlyYmd(),
          maxDate: DateTime.now().onlyYmd().add(1.days),
        ).paddingSymmetric(horizontal: 12),
        gap4,
        // _buildTabView().expand()
        _buildDialyView().expand(),
      ],
    ).stack(
        supplier: (self) => [
              self,
              Obx(() {
                var atSameDayAs = _startTime.isAtSameDayAs(FnDateUtils.now.value);
                if (atSameDayAs) return emptyWidget;
                return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _startTime = DateTime.now().onlyYmd();
                        _endTime = _startTime.add(1.days);
                      });
                    },
                    child: Text(
                      "今天".i18n,
                    ));
              }).position(
                left: 20,
                bottom: 20,
              )
            ]);
  }

  final GlobalKey<TimeBlockTimeLineState> _key = GlobalKey();
  final GlobalKey<FnWeekViewState> _weekViewKey = GlobalKey();

  Widget _buildDialyView() {
    return StreamBuilder(
        stream: _search(),
        builder: (BuildContext context, AsyncSnapshot<List<TimeBlock>> snapshot) {
          List<TimeBlock>? tbs = snapshot.data;
          if (tbs == null) return emptyWidget;
          List<TimeBlock> list = tbs.whereToList((e) => e.startTime != null);
          if (_weekViewKey.currentContext != null) {
            runOnNextFrame(() => _weekViewKey.currentState?.refresh(list));
          }
          return FnWeekView(
            key: _weekViewKey,
            autofocus: false,
            timeBlocks: list,
            startTime: _startTime ?? DateTime.now().onlyYmd(),
            endTime: _endTime ?? DateTime.now().onlyYmd().add(1.days),
          );
        });
  }

  Widget _buildTabView() {
    return StreamBuilder(
        stream: _search(),
        builder: (BuildContext context, AsyncSnapshot<List<TimeBlock>> snapshot) {
          List<TimeBlock>? tbs = snapshot.data;
          if (tbs == null) return emptyWidget;
          List<TimeBlock> list = tbs.whereToList((e) => e.startTime != null);
          if (_key.currentContext != null) {
            runOnNextFrame(() => _key.currentState?.updateList(list));
          }
          return TimeBlockTimeLine(
            tbs: tbs,
            key: _key,
            minTime: _startTime.onlyYmd(),
            maxTime: _endTime.onlyYmd(),
          );
        });
  }

  Stream<List<TimeBlock>> _search() {
    // 模拟输出一波 stream
    // return Stream.fromIterable([GuideData.guideTimeBlock]);
    return TimeBlockStore.find
        .queryPromodoByTime(startTime: _startTime, endTime: _endTime.subtract(1.milliseconds))
        .watch()
        .distinct((a, b) => a.deepEqual(b, (i) => i.uniqueKey));
  }
}
