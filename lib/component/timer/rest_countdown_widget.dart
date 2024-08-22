import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/short_cut/fn_actions.dart';
import 'package:flutter_pasteboard/component/timer/focus_countdown_widget.dart';
import 'package:flutter_pasteboard/component/timer/pomodoro_edit_time.dart';
import 'package:flutter_pasteboard/component/timer/pomodoro_timer_extension.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/single_service.dart';
import 'package:flutter_pasteboard/theme/text_theme.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:ui_extension/ui_extension.dart';

class RestCountDownWidget extends StatelessWidget with FastUpdateTime, CountDownWidgetMixin {
  const RestCountDownWidget({
    super.key,
    required this.timeStyle,
    required this.tbRx,
    this.onTap,
  });

  @override
  final Rx<TimeBlock> tbRx;
  final TextStyle? timeStyle;
  final void Function(TimeBlock tb)? onTap;

  bool get showTimeBtn => $zenService.state.isTimeOut;

  bool get isNeg => tbRx.value.leftSeconds < 0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (tbRx.value.isFocus) return errorWidget("no support focus");
      var rest = tbRx.value.rest;
      var leftSeconds = tbRx.value.leftSeconds;
      var progressSeconds = $zenService.isRest ? rest.progressSeconds : rest.durationSeconds;
      var duration = isNeg ? progressSeconds.seconds : leftSeconds.seconds;
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          builtTimeText(duration, timeStyle: timeStyle),
          _buildTimeBottomBtn(context, leftSeconds),
        ],
      );
    });
  }

  Row _buildTimeBottomBtn(BuildContext context, int leftSeconds) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showTimeBtn)
          TextButton(
              onPressed: () {
                subDuration(2);
              },
              child: Text("-2 min").guideToolTip(FnActions.SubtractFiveMinutes.keySet)),
        gap4,
        Obx(() {
          var tb = tbRx.value;
          var now = FnDateUtils.now.value;
          var startTime = tb.startTime ?? now;
          var style = context.bodyMedium.copyWith(
            fontWeight: FontWeight.w400,
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    startTime == now ? "now".i18n : FnDateUtils.humanReadable(startTime),
                    style: style,
                  ),
                  gap4,
                  Icon(
                    HeroIcons.arrow_small_right,
                    size: 12,
                  ),
                  gap4,
                  _buildEndTime(style),
                ],
              ).paddingSymmetric(horizontal: 12, vertical: 4).material(color: context.onBackground.withOpacity(.1)).inkWell(onTap: () {
                onTimeTextTap();
              }),
              if (isNeg)
                Obx(() => Text(
                      "${FnDateUtils.formatDuration_hh_mm(tbRx.value.durationSeconds.seconds)} + ${FnDateUtils.formatDuration_hh_mm(leftSeconds.abs().seconds)}",
                      style: context.bodySmall.withOpacity(.3),
                    )),
            ],
          );
        }),
        gap4,
        if (showTimeBtn)
          TextButton(
              onPressed: () {
                addDuration(2);
              },
              child: Text("+2 min").guideToolTip(FnActions.AddFiveMinutes.keySet)),
      ],
    );
  }

  Obx _buildEndTime(TextStyle style) {
    return Obx(() {
      var msg = tbRx.value.planEndTime?.smartFormate(DateTime.now());
      return Text(
        "${msg ?? "now".i18n}",
        style: style,
      );
    });
  }

  void onTimeTextTap() {
    if (onTap != null) {
      onTap!.call(tbRx.justValue);
    } else {
      showEditTime(tbRx);
    }
  }
}
