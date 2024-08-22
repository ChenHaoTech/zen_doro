import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/audio/audio_mix_widget.dart';
import 'package:flutter_pasteboard/component/meature/measure_sizer_widget.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/component/timer/pomodoro_edit_time.dart';
import 'package:flutter_pasteboard/component/timer/pomodoro_timer_extension.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/fn_audioservice.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:flutter_pasteboard/theme/text_theme.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:ui_extension/ui_extension.dart';

class FocusCountDownWidget extends StatelessWidget with FastUpdateTime, CountDownWidgetMixin {
  const FocusCountDownWidget({
    super.key,
    required this.timeStyle,
    required this.tbRx,
    this.onTap,
    this.canShowTimeBtn = true,
  });

  final bool canShowTimeBtn;
  @override
  final Rx<TimeBlock> tbRx;
  final TextStyle? timeStyle;
  final void Function(TimeBlock tb)? onTap;

  bool get isNeg => tbRx.value.leftSeconds < 0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var pomodoro = tbRx.value.pomodoro;
      var leftSeconds = pomodoro.leftSeconds;
      var progressSeconds = $zenService.isFocus ? pomodoro.progressSeconds : pomodoro.durationSeconds;
      var duration = isNeg ? progressSeconds.seconds : leftSeconds.seconds;
      // DebugUtils.log("focus_countdown_widget:47 \n${StackTrace.current}");
      return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAudioConfig(),
            builtTimeText(duration, timeStyle: timeStyle),
            _buildTimeBottomBtn(
              context,
              leftSeconds,
              constraints,
            ),
          ],
        );
      });
    });
  }

  SizedBox _buildAudioConfig() {
    return SizedBox(
      height: 24,
      child: Builder(builder: (context) {
        return Obx(() {
          var name = FnAudioService.instance.curAduiMixs.value.name;
          var isMute = FnAudioService.instance.isMute;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isMute ? Icons.headset_off_outlined : Icons.headset_mic_outlined,
                size: 16,
              ).inkWell(onTap: () => FnAudioService.instance.toggleMute()),
              gap4,
              Text(
                name,
                style: context.defaultTextStyle.copyWith(
                  decoration: TextDecoration.combine([
                    TextDecoration.underline,
                    if (isMute) TextDecoration.lineThrough,
                  ]),
                  color: context.primary,
                ),
              ),
            ],
          ).inkWell(onTap: () {
            showAuioMixWidget();
          });
        }).opacity(.4);
      }),
    );
  }

  bool get showTimeBtn => canShowTimeBtn && $zenService.state.isTimeOut;

  Widget _buildTimeBottomBtn(
    BuildContext context,
    int leftSeconds,
    BoxConstraints constraints,
  ) {
    var maxWidth = constraints.maxWidth;
    final Rx<int?> sizeRx = Rx(null);
    bool isSizeEnough() {
      var value = sizeRx.value;
      return value == null || value < maxWidth / 2;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showTimeBtn)
          Obx(() {
            if (!isSizeEnough()) return emptyWidget;
            return TextButton(
              onPressed: () {
                subDuration(5);
              },
              child: Text("-5 min").guideToolTip(FnActions.SubtractFiveMinutes.keySet),
            ).paddingOnly(right: 4);
          }),
        MeasureSize(
          onChange: (Size size) {
            sizeRx.value = size.width.round();
            // DebugUtils.log("focus_countdown_widget:137: ${size} ${maxWidth}\n${StackTrace.current}");
          },
          child: Obx(() {
            var tb = tbRx.value;
            var now = FnDateUtils.now.value;
            var startTime = tb.startTime ?? now;
            if (tb.isRest) return emptyWidget;
            var promodo = tb.pomodoro;
            var endTime = FnDateUtils.now.value.add((promodo.leftSeconds ~/ 60).minutes);
            var isPlay = $zenService.state == PomodoroState.Focus;
            var style = context.bodyMedium.copyWith(
              fontWeight: FontWeight.w400,
              color: isPlay ? null : context.primary.withOpacity(.6),
            );

            var child = Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  startTime == now ? "now".i18n : startTime.relativeFormate(),
                  style: style,
                ),
                gap4,
                Icon(
                  HeroIcons.arrow_small_right,
                  size: 12,
                ),
                gap4,
                Obx(() {
                  var state = $zenService.state;
                  switch (state) {
                    case PomodoroState.FocusPause:
                      return Text(
                        "暂停".i18n,
                        style: style,
                      );
                    case PomodoroState.Focus:
                      return Text(
                        FnDateUtils.humanReadable(endTime),
                        style: style,
                      );
                    case PomodoroState.FocusTimeEnd:
                      return Text(
                        "超时",
                        style: style,
                      );
                    case PomodoroState.Edit:
                    case PomodoroState.FocusFeedBack:
                      return Obx(() => Text(
                            "${FnDateUtils.humanReadable((tbRx.value.startTime ?? now).add(tbRx.value.durationSeconds.seconds)).takeIf((it) => !it.isEmptyOrNull) ?? "---".i18n}",
                            style: style,
                          ));
                    default:
                      return errorWidget("${state}");
                  }
                }),
              ],
            ).paddingSymmetric(horizontal: 12, vertical: 4).material(color: context.onBackground.withOpacity(.1));
            var timeWidget = child
                .opacity(
                  isPlay ? 0.5 : 1,
                )
                .tooltip((isPlay ? "${(endTime.difference(startTime).inSeconds / 60).ceil()} min" : "") + " ${FnKeys.cmdT.toReadable()}")
                .inkWell(onTap: () {
              onTimeTextTap();
            });
            return Column(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    timeWidget,
                    if (promodo.leftSeconds < 0)
                      Text(
                        "${FnDateUtils.formatDuration_hh_mm(promodo.durationSeconds.seconds)} + ${FnDateUtils.formatDuration_hh_mm(leftSeconds.abs().seconds)}",
                        style: context.bodySmall.withOpacity(.3),
                      ),
                  ],
                ),
              ],
            );
          }),
        ),
        if (showTimeBtn)
          Obx(() {
            if (!isSizeEnough()) return emptyWidget;
            return TextButton(
              onPressed: () {
                addDuration(5);
              },
              child: Text("+5 min").guideToolTip(FnActions.AddFiveMinutes.keySet),
            ).paddingOnly(left: 4);
          }),
      ],
    ).boxConstraints(maxWidth: maxWidth);
  }

  void onTimeTextTap() {
    if (onTap != null) {
      onTap!.call(tbRx.justValue);
    } else {
      showEditTime(tbRx);
    }
  }
}

abstract mixin class CountDownWidgetMixin {
  Widget builtTimeText(
    Duration duration, {
    TextStyle? timeStyle,
  }) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${FnDateUtils.formatDuration_hh_mm(duration)}",
            style: timeStyle?.copyWith(
              color: timeStyle?.color?.withOpacity($zenService.state == PomodoroState.FocusPause ? .4 : 1),
              fontSize: min(Get.width, constraints.maxWidth) * .2,
            ),
          ).inkWell(onTap: () {
            onTimeTextTap();
          }),
        ],
      );
    });
    ;
  }

  void onTimeTextTap();
}
