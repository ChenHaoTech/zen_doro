import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/archive/stats_controller.dart';
import 'package:flutter_pasteboard/component/timer/feedback_const.dart';
import 'package:get/get.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:ui_extension/ui_extension.dart';

class EmotionStatsCardMobile extends StatefulWidget {
  const EmotionStatsCardMobile({super.key});

  @override
  State<EmotionStatsCardMobile> createState() => _StatsCardState();
}

class _StatsCardState extends State<EmotionStatsCardMobile> {
  RxList<TimeBlock> get _timeBlocks => StatsController.instance.timeBlocks;

  @override
  Widget build(BuildContext context) {
    var res = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "番茄分布统计".i18n,
          style: context.labelLarge,
        ).paddingSymmetric(
          horizontal: 12,
        ),
        gap12,
        Obx(() {
          var timeBlocks = _timeBlocks.value;
          if (timeBlocks.isEmpty) {
            return Text("此时间段无番茄".i18n).opacity(.4).center();
          }

          var emojis = timeBlocks.where((e) => e.isFocus).mapToSet((e) => e.pomodoro.feedback ?? "?").toList()..sort();
          var colors = emojis.mapIdx((idx, i) => (i, feedbackEmojisColor[i] ?? Colors.grey));
          var date2Tbs = timeBlocks.groupListsBy((i) => i.startTime!.onlyYmd());
          var dates = date2Tbs.keys.toList();
          dates.sort();
          List<(/*title*/ String, /*list by category*/ List<double>)> datas = [];
          var formate = FnDateUtils.mmd_notime;
          for (var date in dates) {
            var tbs = date2Tbs[date];
            fnassert(() => tbs != null, "${date2Tbs}, ${date}");
            List<double> scores =
                emojis.map((emoji) => tbs!.where((e) => e.isFocus && e.pomodoro.feedback == emoji).length).mapToList((e) => e.toDouble());
            datas.add((formate.format(date), scores));
          }
          this.log.dd(() => "colors:${colors}, datas:${datas}");

          return emptyWidget;
          // return FnBarChar(
          //   config: BarCharConfig(colors: colors, datas: datas),
          // );
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
}
