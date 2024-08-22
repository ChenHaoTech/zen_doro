import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/clock/analog_clock.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/component/short_cut/h_shortcut_widget.dart';
import 'package:flutter_pasteboard/component/timer/pomodoro_timer_extension.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:flutter_pasteboard/service/time_rule_misc.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

class PomodoroRestDashboardDesktop extends StatefulWidget {
  PomodoroRestDashboardDesktop({Key? key}) : super(key: key);

  @override
  State<PomodoroRestDashboardDesktop> createState() => _PomodoroRestDashboardDesktopState();
}

class _PomodoroRestDashboardDesktopState extends State<PomodoroRestDashboardDesktop> with ITimeBlockOnRest, FastUpdateTime {
  final _focusNode = FocusNode();

  //todo 修改

  @override
  void initState() {
    super.initState();
    Future.delayed(.1.seconds, () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(48),
              child: Row(
                children: [
                  gap12,
                  const Spacer(),
                  // FnPopUpMenu(
                  //   tooltip: "切换休息类型".i18n,
                  //   configs: [
                  //     PopUpMenuConfig.textBtn("倒计时".i18n, () {
                  //       _restType.value = RestType.COUNT_DOWN;
                  //       if (isRest) {
                  //         $zenService.switchRestType(_restType.justValue);
                  //       } else {
                  //         _fallbackRestTb = _fallbackRestTb.switchRestType(_restType.justValue);
                  //       }
                  //     }),
                  //     PopUpMenuConfig.textBtn("正计时".i18n, () {
                  //       _restType.value = RestType.POSITIVE_TIMING;
                  //       if (isRest) {
                  //         $zenService.switchRestType(_restType.justValue);
                  //       } else {
                  //         _fallbackRestTb = _fallbackRestTb.switchRestType(_restType.justValue);
                  //       }
                  //     }),
                  //   ],
                  //   child: Obx(() {
                  //     var style = context.bodyMedium.copyWith(
                  //       color: context.primary,
                  //       decoration: TextDecoration.underline,
                  //     );
                  //     if (_restType.value == RestType.COUNT_DOWN) {
                  //       return Text("倒计时".i18n, style: style);
                  //     } else {
                  //       return Text("正计时".i18n, style: style);
                  //     }
                  //   }),
                  // ).boxConstraints(maxHeight: 68, maxWidth: 180),
                  gap24,
                ],
              ).paddingOnly(top: 4)),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              debugTb(),
              Builder(builder: (context) {
                return Obx(() {
                  if (restType.value == RestType.COUNT_DOWN) {
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
                  } else {
                    return _buildPositiveTimer();
                  }
                });
              }).expand(),
              Obx(() {
                var isNotRest = $zenService.state != PomodoroState.Rest;
                return SizedBox(
                  height: Get.height / 4,
                  child: buildBtnOnRest(context),
                );
              }),
            ],
          ),
        )
            .focus(
          focusNode: _focusNode,
        )
            .easyTap(onTap: () {
          _focusNode.requestFocus();
        });
      },
    ).safeArea().blurOnUnFocus().simpleShortcuts(_short);
  }

  late final _short = {
    FnActions.ResetRest: () {
      resetRest();
    },
    FnActions.SubtractFiveMinutes: () {
      subDuration(2);
    },
    FnActions.AddFiveMinutes: () {
      addDuration(2);
    },
    FnActions.StopRest: () {
      stopRest();
    },
    FnActions.StartRest: () {
      startRest();
    },
    FnActions.DiscardCurrentRest: () {
      discard();
    },
  };

  Widget _buildPositiveTimer() {
    return LayoutBuilder(builder: (context, c) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnalogClock(
            decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: Colors.black),
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            width: c.maxWidth * .6,
            isLive: true,
            hourHandColor: Colors.black,
            minuteHandColor: Colors.black,
            showSecondHand: false,
            numberColor: Colors.black87,
            showNumbers: true,
            showAllNumbers: false,
            textScaleFactor: 1.4,
            showTicks: true,
            showDigitalClock: true,
            digitalClockContext: () {
              if (!isRest) {
                return "";
              }
              var rest = $zenService.curTimeBlock.rest;
              var left = rest.progressSeconds.seconds.inMinutes.toString().padLeft(2, '0');
              var right = (rest.progressSeconds.seconds.inSeconds % 60).toString().padLeft(2, '0');
              return "${left}:${right}";
            },
            datetime: DateTime.now(),
          ),
        ],
      );
    });
  }

  @override
  Rx<TimeBlock> get tbRx => $zenService.$curTimeBlock;
}
