import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/theme/padding_constants.dart';
import 'package:flutter_pasteboard/theme/text_theme.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/component/fn_popMenu.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/archive/stats_controller.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/stats_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:ui_extension/ui_extension.dart';

/**
 *
 * @author chenhao91
 * @date   2024/4/1
 */
class FnTextStatsView extends StatefulWidget {
  const FnTextStatsView({super.key});

  @override
  _FnTextStatsViewState createState() => _FnTextStatsViewState();
}

class _FnTextStatsViewState extends State<FnTextStatsView> {
  StatsController get controller => StatsController.instance;

  get _groupType => controller.groupType;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            /*     Wrap().expand(),
            gap12,*/
            Spacer(),
            Text("分组".i18n),
            gap12,
            FnPopUpMenu(
              configs: [
                PopUpMenuConfig.textBtn("按周".i18n, () => _groupType.value = GroupType.Week),
                PopUpMenuConfig.textBtn("按日期".i18n, () => _groupType.value = GroupType.Date),
                PopUpMenuConfig.textBtn("按标签".i18n, () => _groupType.value = GroupType.Tag),
              ],
              child: Obx(() {
                if (_groupType.value == GroupType.Week) {
                  return Text("按周");
                } else if (_groupType.value == GroupType.Date) {
                  return Text("按日期");
                } else if (_groupType.value == GroupType.Tag) {
                  return Text("按标签");
                }
                throw "暂不支持";
              }).opacity(
                .4,
              ),
            ),
            gap12,
          ],
        ).paddingOnly(
          right: 12,
          top: 4,
          bottom: 4,
        ),
        Obx(() {
          var originText = parse(_groupType.value);
          if (originText.isEmptyOrNull) {
            return Text(
              "点击(${FnKeys.cmdN.toReadable()}) 添加记录",
              style: context.titleLarge.copyWith(
                color: context.onBackground.withOpacity(.4),
              ),
            ).center().inkWell(onTap: () {
              controller.createNewOne();
            });
          }
          return MarkdownWidget(
            data: originText,
            // config: config.copy(configs: [isDark ? PreConfig.darkConfig.copy(wrapper: codeWrapper) : PreConfig().copy(wrapper: codeWrapper)]));
          );
        }).expand(),
      ],
    );
  }

  String parse(
    GroupType type,
  ) {
    Map<String, List<TimeBlock>> map = {};
    List<TimeBlock> tbs = controller.timeBlocks;
    switch (type) {
      case GroupType.Week:
        String _parseWeek(DateTime date) {
          // 获取当前周的第一天
          DateTime startOfWeek = date.subtract(Duration(days: date.weekday - 1));
          // 获取当前周的最后一天
          DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

          return '${FnDateUtils.ymmd_notime.format(startOfWeek)} - ${FnDateUtils.ymmd_notime.format(endOfWeek)} ';
        }

        map = tbs.groupListsBy((TimeBlock p0) => _parseWeek(p0.startTime!));
      case GroupType.Date:
        map = tbs.groupListsBy((TimeBlock p0) => FnDateUtils.ymmd_notime.format(p0.startTime!.onlyYmd()));
      case GroupType.Tag:
        map = tbs.where((e) => e.isFocus).groupListsBy((TimeBlock p0) => () {
              var _tags = p0.pomodoro.tags.toList()..sort();
              return _tags.join(",");
            }());
      default:
        throw "un impl";
    }
    return map
        .mapToList((p0, p1) => """
# ${p0}
${p1.sortedBy((e) => e.startTime!).mapToList((i) => i.toMd(
                  showMonthDay: type != GroupType.Date,
                  debug: staticDebugMode,
                )).join("\n")}    
""")
        .join("\n\n");
  }
}
