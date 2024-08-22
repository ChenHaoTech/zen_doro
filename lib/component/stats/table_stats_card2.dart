import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/widget/fn_bar_char.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/widget/fn_pie_char.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';
import 'package:flutter_pasteboard/theme/text_theme.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:ui_extension/ui_extension.dart';

class TableStatsCard2 extends StatefulWidget {
  final List<TimeBlock> timeBlocks;
  final String title;
  final Widget Function(String)? keyMapper;
  final Map<String, List<TimeBlock>> Function(List<TimeBlock> timeBlocks) groupByFunction;

  TableStatsCard2({super.key, required this.timeBlocks, required this.title, required this.groupByFunction, this.keyMapper});

  @override
  State<TableStatsCard2> createState() => _StatsCardState();
}

enum SortKey {
  title,
  time,
}

class _StatsCardState extends State<TableStatsCard2> {
  late List<TimeBlock> _timeBlocks = [];
  late final Map<String, List<TimeBlock>> map;
  final RxSet<String> _hides = RxSet();
  final Map<String, PieConfig> configsMap = {};
  final List<(/*title*/ String, /*list by category*/ Map<String, double>)> datas = [];
  final List<(/*category*/ String, Color)> colors = [];
  num sum = 0;
  late final PieChartRxHolder rxHolder;
  SortKey? _sortKey;
  bool reverse = false;
  late final StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _timeBlocks = widget.timeBlocks.whereToList((p0) => p0.isFocus);
    map = widget.groupByFunction.call(_timeBlocks);

    var titles = map.keys;
    for (var key in titles) {
      var value = map[key]!;
      var res = value.sum((i) => i.progressSeconds);
      if (res == 0) continue;
      Color color = value.first.color?.withOpacity(Random().nextDouble()) ?? Get.touch(() => FnColors.tagColors.random, tag: "table2_statis_${key}");
      var pieConfig = PieConfig(
        value: (res / 60).toInt(),
        title: key,
        extra: key,
        color: color,
        hover: false.obs,
      );
      configsMap[key] = pieConfig;
      colors.add((key, color));
    }
    var configs = configsMap.values.toList();
    sum = configs.sum((p0) => p0.value);
    rxHolder = PieChartRxHolder(configs, sum.toInt());
    rxHolder.init();
    _sub = _hides.listen((p0) {
      rxHolder.hides.clear();
      rxHolder.hides.value = rxHolder.all.whereToList((e) => p0.contains(e.title));
    });

    var date2Tbs = _timeBlocks.groupListsBy((i) => i.startTime!.onlyYmd());
    var dates = date2Tbs.keys.toList();
    var findMin = FnDateUtils.findMin(dates);
    var findMax = FnDateUtils.findMax(dates);
    if (findMin == null || findMax == null) return;
    // 从findMin-> 遍历到findMax,
    var currentDate = findMin;
    var formate = FnDateUtils.mmd_notime;
    while (currentDate.isBefore(findMax) || currentDate.isAtSameMomentAs(findMax)) {
      // 在这里处理每一天的逻辑
      var tbs = date2Tbs[currentDate];
      if (tbs == null) {
        datas.add((formate.format(currentDate), {}));
      } else {
        var scores = widget.groupByFunction.call(tbs).map((k, v) => MapEntry(k, v.sum((p0) => p0.progressSeconds / (60 * 60)) as double));
        datas.add((formate.format(currentDate), scores));
      }
      currentDate = currentDate.add(Duration(days: 1));
    }
  }

  @override
  void dispose() {
    super.dispose();
    rxHolder.dispose();
    _sub.cancel();
  }

  DataRow _buildTableLine(String key) {
    var keyWidget = widget.keyMapper?.call(key) ??
        Text(
          key,
          overflow: TextOverflow.ellipsis,
        );
    var tagValue = map[key]?.firstOrNull?.tryPromodo?.tags.firstOrNull;
    var tag = tagValue?.fnmap((val) => TagStore.find.id2tag[val]);
    var config = configsMap[key]!;
    return DataRow(
        selected: !_hides.contains(key),
        onSelectChanged: (selected) {
          _hides.toggle(key);
        },
        cells: [
          Builder(builder: (context) {
            var row = Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color: config.color,
                  width: 12,
                  height: 12,
                ),
                gap12,
                keyWidget.expand(),
              ],
            );
            return row.inkWell(onHover: (hover) {
              config.hover?.value = hover;
            });
          }),
          Builder(builder: (context) {
            return Text(
              tag?.value.toString() ?? "",
              style: context.defaultTextStyle.withColor(tag?.color?.withLightness(.7)),
            );
          }),
          Text("${(config.value / sum * 100).toStringAsFixed(1)}%").paddingSymmetric(horizontal: 8, vertical: 2).opacity(.6),
          Text(prettyDuration(tersity: DurationTersity.minute, abbreviated: true, config.value.minutes))
              .paddingSymmetric(horizontal: 8, vertical: 2)
              .opacity(.6),
        ].mapToList((e) => DataCell(e)));
  }

  @override
  Widget build(BuildContext context) {
    if (_timeBlocks.isEmptyOrNull) return Text("啊哦!没有任何记录😂".i18n).opacity(.4).center();
    var titleStyle = context.titleMedium.copyWith(fontWeight: FontWeight.w500);
    var table = Obx(() {
      return DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: context.isMobile ? 100 : 600,
        columns: [
          DataColumn2(
            label: Text(
              widget.title,
              style: titleStyle,
            ),
            size: ColumnSize.L,
            onSort: (idx, asc) {
              setState(() {
                if (_sortKey == SortKey.title) {
                  reverse = !reverse;
                } else {
                  _sortKey = SortKey.title;
                }
              });
            },
          ),
          DataColumn2(
            label: Text(
              "Tag".i18n,
              style: titleStyle,
            ),
          ),
          DataColumn2(
            label: Text(
              "比例".i18n,
              style: titleStyle,
            ),
            onSort: (idx, asc) {
              setState(() {
                if (_sortKey == SortKey.time) {
                  reverse = !reverse;
                } else {
                  _sortKey = SortKey.time;
                }
              });
            },
          ),
          DataColumn2(
            label: Text(
              "总时间".i18n,
              style: titleStyle,
            ),
            onSort: (idx, asc) {
              setState(() {
                if (_sortKey == SortKey.time) {
                  reverse = !reverse;
                } else {
                  _sortKey = SortKey.time;
                }
              });
            },
          ),
        ],
        rows: _buildRows(),
      );
    }).boxConstraints(maxHeight: map.keys.length > 4 ? 400 : 200);
    return table;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        table,
        LayoutBuilder(builder: (context, c) {
          var padding = 12.0;
          return Row(
            children: [
              SizedBox(
                width: padding,
              ),
              SingleChildScrollView(
                child: _buildBar().boxConstraints(maxWidth: c.maxWidth - padding * 2),
                scrollDirection: Axis.horizontal,
              ).expand(),
              SizedBox(
                width: padding,
              ),
            ],
          ).boxConstraints(maxHeight: 200);
        })
      ],
    );
  }

  List<DataRow> _buildRows() {
    var keys = configsMap.keys.toList();
    var sortKey = _sortKey ?? SortKey.time;
    if (sortKey == SortKey.time) {
      keys = keys.sorted((a, b) => configsMap[b]!.value.compareTo(configsMap[a]!.value));
    } else if (sortKey == SortKey.title) {
      keys = keys.sorted((a, b) => configsMap[a]!.title.compareTo(configsMap[b]!.title));
    }
    if (reverse) {
      keys = keys.reversed.toList();
    }
    return keys.mapToList((p0) => _buildTableLine(p0));
  }

  Widget _buildBar() {
    return Obx(() {
      var hides = _hides;
      var whereToList = datas.mapToList((p0) {
        var map = Map<String, double>.from(p0.$2);
        map.removeWhere((k, v) => hides.contains(k));
        return (p0.$1, map);
      });
      if (whereToList.isEmpty) return emptyWidget;
      return FnBarChar(
        key: UniqueKey(),
        config: BarCharConfig(colors: colors, datas: whereToList),
      );
    });
  }
}
