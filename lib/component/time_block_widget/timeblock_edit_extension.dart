import 'dart:math';

import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:duration/duration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/editor/duration_editor.dart';
import 'package:flutter_pasteboard/component/editor/time_eidtor.dart';
import 'package:flutter_pasteboard/component/editor/task_editor.dart';
import 'package:flutter_pasteboard/component/timer/feedback_const.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/fn_notification.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/theme/text_theme.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:simple_time_range_picker/simple_time_range_picker.dart';
import 'package:ui_extension/ui_extension.dart';

abstract class ITimeBlockEditor {
  Rx<TimeBlock> get tbRx;
}

extension TimeBlockEditExt on ITimeBlockEditor {
  Widget buildStartTime({
    bool autofocus = false,
    bool autoUpdateEndTime = false,
    FocusNode? focusNode,
    void Function()? onEditingComplete,
    Widget? subWidget,
    DateTime? maxTime,
    DateTime? minTime,
  }) {
    final GlobalKey<TimeEditorState> _key = GlobalKey();
    return Builder(builder: (context) {
      return ListTile(
        title: Obx(() {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("开始日期".i18n),
              gap4,
              Text(
                '${tbRx.value.startTime?.onlyYmd().formate(DateFormat("yyyy MM dd"))}',
                style: context.defaultTextStyle.withOpacity(.9),
              ),
              Icon(Icons.arrow_drop_down, size: 16).opacity(.7),
            ],
          ).inkWell(onTap: () async {
            var dateTime = await showDatePicker(
              context: context,
              initialDate: tbRx.justValue.startTime,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (dateTime != null) {
              var startTime = tbRx.value.startTime;
              var startTime2 = dateTime.copyWith(
                hour: startTime?.hour,
                minute: startTime?.minute,
              );
              tbRx.value = tbRx.justValue
                  .updateDurationByStartTimeDiffWhenEndIsNull(startTime2)
                  .updateTime(
                    startTime: startTime2,
                  )
                  .correctEndTime();
            }
          });
        }),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTimeSpendDetail().inkWell(onTap: () async {
              var now = DateTime.now();
              DateTime starTime = tbRx.justValue.startTime ?? now;
              TimeRangePicker.show(
                  startTime: TimeOfDay.fromDateTime(starTime),
                  endTime: TimeOfDay.fromDateTime(tbRx.justValue.endTime ?? tbRx.justValue.progressEndTime!),
                  context: context,
                  onSubmitted: (TimeRangeValue result) {
                    print("${result.startTime} - ${result.endTime}");
                    var newStart = starTime.copyWith(hour: result.startTime?.hour, minute: result.startTime?.minute);
                    if (newStart.isAfter(DateTime.now())) {
                      FnNotification.toast("开始时间不能大于当前时间".i18n);
                      return;
                    }
                    var newEnd = starTime.copyWith(hour: result.endTime?.hour, minute: result.endTime?.minute);
                    if (!newEnd.isAfter(newStart)) {
                      FnNotification.toast("结束时间要大于开始时间".i18n);
                      return;
                    }
                    // if (newEnd.isBefore(newStart)) {
                    //   newEnd = newEnd.add(1.days);
                    // }
                    tbRx.value = tbRx.justValue.updateTime(startTime: newStart, endTime: newEnd).correctDuration();
                    // starTime.cop
                    // DebugUtils.log("timeblock_edit_extension:78; ${result} \n${StackTrace.current}");
                  });
            }),
            if (subWidget != null) subWidget,
          ],
        ),
        trailing: Obx(
          () {
            var initTime2 = tbRx.value.startTime ?? DateTime.now();
            _key.currentState?.updateTime(hour: initTime2.hour, minute: initTime2.minute);
            return TimeEditor(
              key: _key,
              autofocus: autofocus,
              focusNode: focusNode,
              initTime: initTime2,
              minTime: minTime,
              maxTime: maxTime ?? FnDateUtils.now.value,
              onEditingComplete: onEditingComplete,
              onUpdate: (TimeOfDay timeOfDay) {
                var startTime = tbRx.value.startTime ?? DateTime.now();
                var startTime2 = startTime.copyWith(
                  hour: timeOfDay.hour,
                  minute: timeOfDay.minute,
                );
                tbRx.value = tbRx.justValue
                    .updateDurationByStartTimeDiffWhenEndIsNull(startTime2)
                    .updateTime(
                      startTime: startTime2,
                    )
                    .correctEndTime();
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildTimeSpendDetail() {
    return Builder(builder: (context) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            var startTime = tbRx.value.startTime;
            if (startTime == null) return Text("now -> ---".i18n);
            var endTime = tbRx.value.endTime;

            var clampNow = FnDateUtils.isClamp(startTime, endTime, FnDateUtils.now.value);
            var style = context.defaultTextStyle.withOpacity(.9);
            if (clampNow) {
              var inMinutes = endTime!.difference(FnDateUtils.now.value).inMinutes;
              return Text("${startTime.formate(FnDateUtils.hhmm)} -> ${endTime.smartFormate(startTime)}(${"now + ${inMinutes}m"})", style: style);
            } else {
              return Text(
                  "${startTime.formate(FnDateUtils.hhmm)} -> ${(endTime ?? (tbRx.value.progressSeconds == 0 ? tbRx.value.planEndTime : tbRx.value.progressEndTime))!.smartFormate(startTime)}",
                  style: style);
            }
          }),
          Icon(
            Icons.arrow_drop_down_sharp,
            size: 16,
          ).opacity(.7)
        ],
      );
    });
  }
}

extension FocusTimeBlockEditorWidgetExt on ITimeBlockEditor {
  void updateFeedback(int idx) {
    tbRx.value = tbRx.justValue.updatePromodo(mapper: (p) => p.copyWith(feedback: feedbackEmojis.getNullable(idx) ?? feedbackEmojis.first));
  }

  ListTile buildPlanDuration({
    FocusNode? focusNode,
    bool Function(Duration duration)? preCheck,
  }) {
    final GlobalKey<DurationEditorState> _key = GlobalKey();
    return ListTile(
      title: Text("计划专注时间".i18n),
      subtitle: Obx(() {
        var durationSeconds = tbRx.value.durationSeconds;
        var progressSeconds = tbRx.value.progressSeconds;
        return Wrap(
          children: [
            Text("${prettyDuration(durationSeconds.seconds, tersity: DurationTersity.minute, abbreviated: true)}"),
            if (progressSeconds ~/ 60 != durationSeconds ~/ 60 && progressSeconds != 0)
              Builder(builder: (context) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "(" + "实际专注时间:" + "${prettyDuration(progressSeconds.seconds, tersity: DurationTersity.minute, abbreviated: true)}" + ")",
                      style: context.disable,
                    ),
                  ],
                );
              }),
          ],
        );
      }),
      trailing: Obx(() {
        var duration = tbRx.value.durationSeconds.seconds;
        _key.currentState?.updateDuration(duration);
        return DurationEditor(
          key: _key,
          focusNode: focusNode,
          onChange: (Duration duration) {
            smartUpdateDuration((p0) => duration.inSeconds);
          },
          preCheck: preCheck,
          init: duration,
        );
      }),
    );
  }

  /**
   * 持续时间, progress和 duration都改
   */
  Widget buildProgressDuration({
    FocusNode? focusNode,
    bool Function(Duration duration)? preCheck,
  }) {
    final RxBool hintFullEditor = RxBool(false);
    final GlobalKey<DurationEditorState> _progressKey = GlobalKey();
    final GlobalKey<DurationEditorState> _durationKey = GlobalKey();
    return Obx(() {
      var title = Text("专注时间".i18n);
      if (hintFullEditor.value) {
        return ListTile(
          focusNode: focusNode,
          title: title,
          subtitle: Row(
            children: <Widget>[
              Obx(() {
                var progressSeconds2 = tbRx.value.progressSeconds.seconds;
                var durationSeconds2 = tbRx.value.durationSeconds.seconds;
                return Text("实际专注".i18n +
                    ":${prettyDuration(progressSeconds2, abbreviated: true)}/" +
                    "计划专注".i18n +
                    ":${prettyDuration(durationSeconds2, abbreviated: true)}");
              }).expand(),
              Obx(() {
                var duration2 = max(tbRx.value.progressSeconds, 0).seconds;
                _progressKey.currentState?.updateDuration(duration2);
                return DurationEditor(
                  key: _progressKey,
                  autofocus: true,
                  onChange: (Duration duration) {
                    fnassert(() => !duration.isNegative);

                    tbRx.value = tbRx.justValue
                        .updateTime(
                          progressSeconds: duration.inSeconds,
                          // durationSeconds: duration.inSeconds,
                        )
                        .correctEndTime(considerPlan: false);
                  },
                  preCheck: preCheck,
                  init: duration2,
                );
              }),
              Text("/"),
              Obx(() {
                var duration2 = max(tbRx.value.durationSeconds, 0).seconds;
                _durationKey.currentState?.updateDuration(duration2);
                return DurationEditor(
                  key: _durationKey,
                  onChange: (Duration duration) {
                    fnassert(() => !duration.isNegative);

                    tbRx.value = tbRx.justValue.updateTime(
                      durationSeconds: duration.inSeconds,
                      // durationSeconds: duration.inSeconds,
                    );
                  },
                  preCheck: preCheck,
                  init: duration2,
                );
              }),
            ],
          ),
        );
      }
      return ListTile(
        title: title,
        subtitle: Obx(() {
          var durationSeconds = tbRx.value.durationSeconds;
          var progressSeconds = tbRx.value.progressSeconds;
          return Row(
            children: [
              Text("${prettyDuration(progressSeconds.seconds, tersity: DurationTersity.minute, abbreviated: true)}"),
              Builder(builder: (context) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("/"),
                    gap4,
                    Text("计划".i18n),
                    gap4,
                    Text(
                      "${prettyDuration(durationSeconds.seconds, tersity: DurationTersity.minute, abbreviated: true)}",
                      style: context.linkStyle,
                    ),
                  ],
                );
              }),
            ],
          ).inkWell(onTap: () {
            hintFullEditor.value = true;
          });
        }),
        trailing: Obx(() {
          var duration2 = max(tbRx.value.progressSeconds, 0).seconds;
          _progressKey.currentState?.updateDuration(duration2);
          return DurationEditor(
            focusNode: focusNode,
            key: _progressKey,
            onChange: (Duration duration) {
              fnassert(() => !duration.isNegative);

              tbRx.value = tbRx.justValue
                  .updateTime(
                    progressSeconds: duration.inSeconds,
                    durationSeconds: duration.inSeconds,
                  )
                  .correctEndTime();
            },
            preCheck: preCheck,
            init: duration2,
          );
        }),
      );
    });
  }

  List<Widget> get updateDurationTimeBtns => [
        OutlinedButton(
            onPressed: () {
              smartUpdateDuration((p0) => p0 - 5 * 60);
            },
            child: Text("-5min".i18n)),
        gap4,
        OutlinedButton(
          onPressed: () {
            smartUpdateDuration((p0) => p0 + 5 * 60);
          },
          child: Text("+5min".i18n),
        ),
      ];

  List<Widget> get updateStartTimeBtns => [
        OutlinedButton(
            onPressed: () {
              var startTime = tbRx.value.startTime ?? DateTime.now();
              var subtract = startTime.subtract(5.minutes).clamp(null, DateTime.now());
              tbRx.value = tbRx.justValue.updateDurationByStartTimeDiffWhenEndIsNull(subtract).updateTime(
                    startTime: subtract,
                  );
            },
            child: Text("-5min".i18n)),
        gap4,
        OutlinedButton(
          onPressed: () {
            var startTime = tbRx.value.startTime ?? DateTime.now();
            var startTime2 = startTime.add(5.minutes).clamp(null, DateTime.now());
            tbRx.value = tbRx.justValue.updateDurationByStartTimeDiffWhenEndIsNull(startTime2).updateTime(
                  startTime: startTime2,
                );
          },
          child: Text("+5min".i18n),
        ),
      ];

  void smartUpdateDuration(int Function(int) mapper) {
    var durationSeconds = tbRx.justValue.durationSeconds;
    var seconds = mapper.call(durationSeconds).ensurePos();
    if (tbRx.justValue.isNotEnd) {
      tbRx.value = tbRx.justValue.updateTime(durationSeconds: seconds).correctEndTime().correctProgressTime();
    } else {
      tbRx.value = tbRx.justValue.updateTime(durationSeconds: (seconds)).correctEndTime().correctProgressTime();
    }
  }

  Widget buildFeedbackEditor() {
    return Obx(() {
      var promodo = tbRx.value.pomodoro;
      return LayoutBuilder(builder: (context, c) {
        var maxHeight = c.maxHeight.takeIf((it) => !it.isInfinite) ?? 60;
        double? computeSize = c.maxWidth.takeIf((it) => !it.isInfinite)?.fnmap((val) => val / (4));
        return SegmentedButton(
            onSelectionChanged: (valSet) {
              tbRx.value = tbRx.justValue.updatePromodo(mapper: (p) => p.copyWith(feedback: valSet.first));
            },
            showSelectedIcon: false,
            segments: () {
              var emojis = feedbackEmojis;
              return List.generate(feedbackEmojis.length, (index) {
                var emoji = emojis.getNullable(index);
                return ButtonSegment(
                    value: emoji,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emoji ?? ""),
                        if (!PlatformUtils.isMobile)
                          Builder(builder: (context) {
                            return Text(
                              "${FnModifyString.alt}${index + 1}",
                              style: context.defaultTextStyle.withOpacity(0.6).withSmaller(1),
                            );
                          }),
                      ],
                    ).sizedBox(width: computeSize, height: min(maxHeight, 30)));
              });
            }(),
            selected: {promodo.feedback?.trim()});
      });
    }).center().sizedBox(height: 40).paddingOnly(bottom: 4);
  }

  Widget buildTitleRaw({
    required TextEditingController textEditingController,
    FocusNode? focusNode,
    bool autofocus = false,
    bool reverse = false,
  }) {
    if (Get.context!.isDesktop) {
      return TaskEditor(
        initTag: tbRx.justValue.tags.firstOrNull,
        focusNode: focusNode,
        autofocus: autofocus,
        reverse: reverse,
        controller: textEditingController,
        onChanged: (val) {
          tbRx.value = tbRx.justValue.updatePromodo(mapper: (p) => p.copyWith(title: val));
        },
        onTagUpdate: (Tag? tag) {
          tbRx.value = tbRx.justValue.updateFocus(
            tag: tag,
            isDeleteTag: tag == null,
          );
        },
      );
    }
    return TaskEditorSimple(
      initTag: tbRx.justValue.tags.firstOrNull,
      focusNode: focusNode,
      autofocus: autofocus,
      controller: textEditingController,
      onChanged: (val) {
        tbRx.value = tbRx.justValue.updatePromodo(mapper: (p) => p.copyWith(title: val));
      },
      onTagUpdate: (Tag? tag) {
        tbRx.value = tbRx.justValue.updateFocus(
          tag: tag,
          isDeleteTag: tag == null,
        );
      },
    );
  }

  Widget buildTitle(
    String? title, {
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return buildTitleRaw(
      textEditingController: TextEditingController(text: title),
      focusNode: focusNode,
      autofocus: autofocus,
    );
  }

  Widget buildContextEditor({
    FocusNode? focusNode,
    bool autofocus = false,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: (controller ?? TextEditingController())..text = tbRx.justValue.pomodoro.context ?? "",
      focusNode: focusNode,
      decoration: FnStyle.normalinputDecorationWithoutBorder.copyWith(
        hintText: "记录你的想法、领悟或困惑🧠".i18n,
      ),
      autofocus: autofocus,
      onChanged: (val) {
        tbRx.value = tbRx.justValue.updatePromodo(mapper: (p) => p.copyWith(context: val));
      },
      maxLines: 5,
      minLines: 3,
    );
  }
}
