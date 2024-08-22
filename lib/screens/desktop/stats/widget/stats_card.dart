import 'dart:math';

import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/archive/stats_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:ui_extension/ui_extension.dart';

class StatsCard extends StatefulWidget {
  const StatsCard({super.key});

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard> {
  RxList<TimeBlock> get _timeBlocks => StatsController.instance.timeBlocks;

  @override
  Widget build(BuildContext context) {
    var res = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "时间统计".i18n,
          style: context.labelLarge,
        ).paddingSymmetric(
          horizontal: 12,
        ),
        gap12,
        Obx(() {
          int sessions = 0;
          int breaks = 0;
          int sessionSeconds = 0;
          int breakSeconds = 0;
          var timeBlocks = _timeBlocks.value;
          var dates = timeBlocks.mapToSet((i) => i.startTime?.onlyYmd()).whereNotNull();
          for (var i in timeBlocks) {
            if (i.isRest) {
              breaks++;
              breakSeconds += i.rest.progressSeconds;
            } else {
              fnassert(() => i.isFocus);
              sessions++;
              var progressSeconds = i.pomodoro.progressSeconds;
              sessionSeconds += max(progressSeconds, 0);
            }
          }
          return GridView.count(
            crossAxisCount: 2,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              _buildNumStats(
                sessions,
                "专注".i18n,
                context.primary,
              ),
              _buildNumStats(
                breaks,
                "休息".i18n,
                context.secondary,
              ),
              _buildDurationStats(
                sessionSeconds.seconds,
                "总专注".i18n,
              ),
              _buildDurationStats(
                breakSeconds.seconds,
                "总休息".i18n,
              ),
              _buildDurationStats(
                (sessionSeconds / max(dates.length, 1)).seconds,
                "平均专注/天".i18n,
              ),
              _buildDurationStats(
                (breakSeconds / max(dates.length, 1)).seconds,
                "平均休息/天".i18n,
              ),
            ],
          ).boxConstraints(
            maxHeight: 180,
            maxWidth: 320,
          );
        }),
      ],
    );
    return Card(
      child: res.paddingSymmetric(
        horizontal: 12,
        vertical: 12,
      ),
    ).paddingSymmetric(
      horizontal: 12,
      vertical: 12,
    );
  }

  Widget _buildNumStats(num num, String desc, [Color? color]) {
    var showNum = num == num.ceil() ? num.toString() : num.toStringAsFixed(2);
    return Builder(builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            // 保留两位小数
            showNum,
            style: context.titleLarge.copyMapper(
              (p0) => p0.copyWith(
                color: color,
              ),
            ),
          ),
          gap4,
          Text(
            desc,
          ).opacity(.4),
        ],
      );
    });
  }

  Widget _buildDurationStats(Duration duration, String desc, [Color? color]) {
    late RichText content;
    TextStyle style = context.titleLarge.copyWith(
      color: color,
    );
    TextStyle prefix = context.bodyMedium.copyWith(
      color: (color ?? context.bodyMedium.color)?.withOpacity(.4),
    );
    if (duration <= 1.hours) {
      content = RichText(
          text: TextSpan(children: [
        TextSpan(
          text: "${duration.inMinutes}",
          style: style,
        ),
        TextSpan(
          text: " min",
          style: prefix,
        ),
      ]));
    } else if (duration > 1.hours && duration <= 1.days) {
      content = RichText(
          text: TextSpan(children: [
        TextSpan(
          text: "${(duration.inMinutes / 60).toStringAsFixed(2)}",
          style: style,
        ),
        TextSpan(
          text: " h",
          style: prefix,
        ),
      ]));
    } else {
      content = RichText(
          text: TextSpan(children: [
        TextSpan(
          text: "${(duration.inMinutes / (60 * 24)).toStringAsFixed(2)}",
          style: style,
        ),
        TextSpan(
          text: " d",
          style: prefix,
        ),
      ]));
    }
    return Builder(builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          content,
          gap4,
          Text(
            desc,
          ).opacity(.4),
        ],
      );
    }).tooltip((duration.inSeconds / 60).toStringAsFixed(2) + " min");
  }
}
