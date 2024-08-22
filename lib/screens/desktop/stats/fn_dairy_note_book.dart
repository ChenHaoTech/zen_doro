import 'dart:math';

import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/time_block_widget/timeblock_function.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/component/extends_text_widget/my_special_text_span_builder.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/archive/stats_controller.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/stats_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:ui_extension/ui_extension.dart';

class FnDailyBook extends StatefulWidget {
  const FnDailyBook({super.key});

  @override
  State<FnDailyBook> createState() => _FnDailyBookState();
}

class _FnDailyBookState extends State<FnDailyBook> {
  StatsController get controller => StatsController.instance;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        var tbs = controller.timeBlocks;
        if (tbs.isEmpty) {
          return Text(
            "点击(${FnKeys.cmdN.toReadable()}) 添加记录",
            style: context.titleLarge.copyWith(
              color: context.onBackground.withOpacity(.4),
            ),
          ).center().inkWell(onTap: () {
            controller.createNewOne();
          });
        }
        return ListView.builder(
          itemBuilder: (_, idx) {
            var tb = tbs.getNullable(idx);
            if (tb == null) return null;
            var child = () {
              if (tb.isRest) {
                return _buildRest(tb);
              }
              fnassert(() => tb.isFocus);
              return _buildPromodo(tb);
            }()
                .easyTap(
              onTap: () => showTimeBlockCardEditor(tb: tb),
            );
            var last = tbs.getNullable(idx - 1);
            if (last == null || last.startTime!.onlyYmd() != tb.startTime!.onlyYmd()) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  gap12,
                  _buildDateBar(tb.startTime!),
                  child,
                ],
              );
            }
            return child;
          },
          itemCount: tbs.length,
          reverse: true,
        ).inkWell(onTap: () => controller.createNewOne());
      },
    );
  }

  final double _heightPer5min = 24 * 2.0;

  //todo 可以拖拽修改
  Widget _buildPromodo(TimeBlock tb) {
    fnassert(() => tb.isFocus);
    var promodo = tb.pomodoro;
    Widget title = ExtendedText(
      promodo.title ?? "",
      specialTextSpanBuilder: MySpecialTextSpanBuilder(
        showAtBackground: true,
      ),
      overflow: TextOverflow.ellipsis,
    );

    var startTime = tb.startTime;
    var endTime = tb.endTime;
    if (startTime != null) {
      title = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(FnDateUtils.humanReadable(startTime)).tooltip(FnDateUtils.ymmd_hhmm.format(startTime)).opacity(.4),
          Text(" (${FnDateUtils.formatDuration_hh_mm(promodo.progressSeconds.seconds)})").opacity(.4),
          gap4,
          title,
          gap4,
          if (promodo.feedback != null) Text("${promodo.feedback!}"),
        ],
      );
    }
    var lifeTimeInSeconds = promodo.progressSeconds;
    if (startTime != null && endTime != null) {
      lifeTimeInSeconds = endTime.difference(startTime).inSeconds;
      fnassert(() => !lifeTimeInSeconds.isNegative);
    }
    var height = _computeHeight(lifeTimeInSeconds);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 左标识
        Container(
          width: 8,
          color: context.primary.withOpacity(.4),
        ),
        gap4,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              if (!staticDebugMode) {
                return emptyWidget;
              }
              return Text(
                "${tb.startTime}=>${tb.endTime} tag: ${promodo.tags.join(" ")}log: ${promodo.pauseSeconds} ${promodo.logs.join(", ")} feedback: ${promodo.feedback}",
                overflow: TextOverflow.ellipsis,
              ).tooltip(promodo.toJsonStr());
            }),
            title.boxConstraints(
              maxHeight: 62,
            ),
            if (promodo.context?.isNotEmpty ?? false)
              Text(
                promodo.context!,
                overflow: TextOverflow.ellipsis,
              ).expand(),
          ],
        ).paddingOnly(
          top: 4,
        ),
      ],
    )
        .container(
          color: context.primary.withOpacity(.2),
          height: height,
        )
        .paddingSymmetric(
          vertical: 1,
        );
  }

  double _computeHeight(int lifeTimeInSeconds) =>
      max(min((min(lifeTimeInSeconds, 25 * 60 * 60) / (5 * 60)) * _heightPer5min, _heightPer5min * 2), _heightPer5min);

  //todo 可以拖拽修改 看看timeline 的实现
  Widget _buildRest(TimeBlock tb) {
    fnassert(() => tb.isRest);
    var rest = tb.rest;
    var startTime = tb.startTime;
    var endTime = tb.endTime;
    Widget? title;
    if (tb.startTime != null) {
      title = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(FnDateUtils.humanReadable(tb.startTime!)).tooltip(FnDateUtils.ymmd_hhmm.format(tb.startTime!)).opacity(.4),
          Text(" (${FnDateUtils.formatDuration_hh_mm(rest.progressSeconds.seconds)}) " + "休息".i18n).opacity(.4),
        ],
      );
    }
    var lifeTimeInSeconds = rest.progressSeconds;
    if (startTime != null && endTime != null) {
      lifeTimeInSeconds = endTime.difference(startTime).inSeconds;
      fnassert(() => !lifeTimeInSeconds.isNegative);
    }
    var height = _computeHeight(lifeTimeInSeconds);
    return Row(
      children: [
        Container(
          width: 8,
          color: Colors.green.withOpacity(.4),
        ),
        gap4,
        if (title != null) title,
      ],
    ).container(
      color: Colors.green.withOpacity(.2),
      height: height + 8,
    );
  }

  Widget _buildEmpty(DateTime startTime, DateTime endTime) {
    var lifeTimeInSeconds = endTime.difference(startTime).inSeconds;
    fnassert(() => !lifeTimeInSeconds.isNegative);
    var height = max(_computeHeight(lifeTimeInSeconds), _heightPer5min * 3.0);
    return Builder(builder: (context) {
      return Container(
        color: context.colorScheme.primaryContainer.withOpacity(.1),
        height: height,
        child: Text(FnDateUtils.formatDuration_hh_mm(
          endTime.difference(startTime),
          needSecond: false,
        )).center().paddingAll(
              12,
            ),
      );
    });
  }

  Widget _buildDateBar(DateTime dateTime) {
    return Builder(builder: (BuildContext context) {
      return Container(
        color: context.colorScheme.primaryContainer.withOpacity(.3),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Text(FnDateUtils.humanReadable(
              dateTime,
              onlyDay: true,
            )).tooltip(FnDateUtils.ymmd_notime.format(dateTime.onlyYmd())),
            Spacer(),
            // TextButton(
            //   onPressed: () {
            //     throw "未实现";
            //   },
            //   child: Text(
            //     "复制",
            //   ).opacity(.4),
            // )
          ],
        ),
      );
    });
  }
// todo 空白区域加上记录

//todo log、restType 持续时间 都没写出来
}
