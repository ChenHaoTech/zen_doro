import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/fn_tabview.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/widget/fn_bar_char.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/widget/fn_pie_char.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

class TableStatsCard extends StatefulWidget {
  final List<TimeBlock> timeBlocks;
  final String title;
  final Widget Function(String)? keyMapper;
  final Color? Function(String)? colorSupplier;
  final DateTime? maxTime;
  final DateTime? minTime;
  final Map<String, List<TimeBlock>> Function(List<TimeBlock> timeBlocks) groupByFunction;

  const TableStatsCard({
    super.key,
    required this.timeBlocks,
    required this.title,
    required this.groupByFunction,
    this.keyMapper,
    this.colorSupplier,
    this.maxTime,
    this.minTime,
  });

  @override
  State<TableStatsCard> createState() => _StatsCardState();
}

enum SortKey {
  title,
  time,
}

class _StatsCardState extends State<TableStatsCard> {
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
      Color color = widget.colorSupplier?.call(key) ?? Get.touch(() => FnColors.tagColors.random, tag: "table1_statis_${key}");
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
    if (sum == 0) {
      fnassert(() => configs.every((element) => element.value == 0));
    }
    rxHolder = PieChartRxHolder(configs, sum.toInt());
    rxHolder.init();
    _sub = _hides.listen((p0) {
      rxHolder.hides.clear();
      rxHolder.hides.value = rxHolder.all.whereToList((e) => p0.contains(e.title));
    });

    /*兼容 日 和跨日逻辑*/
    var date2Tbs = _timeBlocks.groupListsBy((i) => i.startTime!.onlyYmd());
    var dates = date2Tbs.keys.toList();
    var findMin = FnDateUtils.findMin([...dates, widget.minTime?.onlyYmd()]);
    var findMax = FnDateUtils.findMax([...dates, widget.maxTime?.onlyYmd()]);
    if (findMin == null || findMax == null) return;
    // 从findMin-> 遍历到findMax,
    if (findMin.onlyYmd() != findMax.onlyYmd()) {
      _onCrossDay(findMin, findMax, date2Tbs);
    } else {
      _onSameDay(findMin, date2Tbs[findMin] ?? []);
    }
  }

  void _onSameDay(DateTime date, List<TimeBlock> tbs) {
    var startOfDay = DateTime(date.year, date.month, date.day);
    var curDate = startOfDay;
    // 对List<TimeBlock>> tbs, 按 startTime 进行小时级别的分类 => <Datetime,list>

    // for 循环, 小时递进
    for (int hour = 0; hour < 23; hour++) {
      // 在这里处理每小时的逻辑
      datas.add((hour.padLeft(2, "0"), {}));
    }

    Map<DateTime, List<TimeBlock>> hourGroupedTbs = {};
    for (var tb in tbs) {
      if (tb.startTime == null) continue;
      var hourKey = tb.startTime!.hour.padLeft(2, "0");
      var values = datas.firstWhere((e) => hourKey == e.$1).$2;
      Map<String, double> scores = widget.groupByFunction.call([tb]).map((k, v) => MapEntry(k, v.sum((p0) => p0.progressSeconds / 60) as double));
      for (var key in scores.keys) {
        values.compute(key, (key, value) => (value ?? 0) + (scores[key] ?? 0));
      }
    }

    //
    // var tbs = date2Tbs[date];
    // if (tbs == null) {
    //   datas.add((formate.format(date), {}));
    // } else {
    //   var scores = widget.groupByFunction.call(tbs).map((k, v) => MapEntry(k, v.sum((p0) => p0.progressSeconds / (60 * 60)) as double));
    //   datas.add((formate.format(date), scores));
    // }
  }

  void _onCrossDay(DateTime findMin, DateTime findMax, Map<DateTime, List<TimeBlock>> date2Tbs) {
    var currentDate = findMin;
    var formate = FnDateUtils.mmd_notime;
    while (currentDate.isBefore(findMax) || currentDate.isAtSameMomentAs(findMax)) {
      // 在这里处理每一天的逻辑
      var tbs = date2Tbs[currentDate];
      if (tbs == null) {
        datas.add((formate.format(currentDate), {}));
      } else {
        var scores = widget.groupByFunction.call(tbs).map((k, v) => MapEntry(k, v.sum((p0) => p0.progressSeconds / 60) as double));
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
    var config = configsMap[key]!;
    return DataRow(
        selected: !_hides.contains(key),
        onSelectChanged: (selected) {
          _hides.toggle(key);
        },
        cells: [
          Builder(builder: (context) {
            var d = clampDouble(sum == 0 ? 0 : config.value / sum, 0, 3);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: config.color.withOpacity(.2),
                  ),
                  width: d * 120,
                  height: 24,
                ).position(left: 0),
                Text("${(d * 100).toStringAsFixed(1)}%").paddingOnly(left: 6),
              ],
            );
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
          Text(prettyDuration(tersity: DurationTersity.minute, abbreviated: true, config.value.minutes))
              .paddingSymmetric(horizontal: 8, vertical: 2)
              .opacity(.6),
        ].mapToList((e) => DataCell(e)));
  }

  double get minWidth => context.isMobile ? 100.0 : 600.0;

  @override
  Widget build(BuildContext context) {
    if (_timeBlocks.isEmptyOrNull) return Text("啊哦!没有任何记录😂".i18n).opacity(.4).center();
    // DebugUtils.log("table_stats_card:243:${_timeBlocks} \n${StackTrace.current}");
    var titleStyle = context.titleMedium.copyWith(fontWeight: FontWeight.w500);
    var table = Obx(() {
      return DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: minWidth,
        columns: [
          DataColumn(
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
          DataColumn(
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
    }).boxConstraints(maxHeight: min(max(300 * (max(map.keys.length, 1) / 4), 100), 600));
    var maxHeight = 300.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        table,
        LayoutBuilder(builder: (context, c) {
          var factor = 200.0;
          var padding = 12.0;
          var isMobile = context.isMobile;
          if (c.maxWidth.isInfinite || c.maxHeight.isInfinite) return Text(c.toString());
          if (isMobile) {
            return FnTabView(tabBinding: [
              (
                Text("基于%s划分//按xx分类,基于xx分类".i18n.fill([widget.title])),
                _buildPie().boxConstraints(maxWidth: c.maxWidth, maxHeight: c.maxHeight),
              ),
              (
                Text("按时间//基于时间".i18n),
                _buildBar().boxConstraints(maxWidth: c.maxWidth, maxHeight: c.maxHeight),
              )
            ]).boxConstraints(maxWidth: c.maxWidth, maxHeight: c.maxHeight);
          }
          return Row(
            children: [
              SizedBox(
                width: padding,
              ),
              _buildPie().boxConstraints(maxWidth: factor),
              SizedBox(
                width: padding,
              ),
              SingleChildScrollView(
                child: _buildBar().boxConstraints(maxWidth: c.maxWidth - factor - padding * 3),
                scrollDirection: Axis.horizontal,
              ).expand(),
              SizedBox(
                width: padding,
              ),
            ],
          );
        }).boxConstraints(maxHeight: maxHeight)
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

  Widget _buildPie() {
    if (rxHolder.shows.isEmpty) return emptyWidget;
    return FnPieChart(
      key: UniqueKey(),
      rxHolder: rxHolder,
      onFilter: (List<PieConfig> pies) {},
    );
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
        valueSupplier: (value) => Text(value < 60 ? '${value}min' : '${value % 60 == 0 ? (value / 60).toInt() : (value / 60).toStringAsFixed(1)}h'),
        config: BarCharConfig(colors: colors, datas: whereToList),
      );
    });
  }
}
