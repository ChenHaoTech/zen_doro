import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/screens/desktop/stats/widget/fn_pie_char.dart';
import 'package:flutter_pasteboard/theme/padding_constants.dart';

class PieStatsCard extends StatefulWidget {
  final List<TimeBlock> tbs;
  final Color Function(String) keyColorsSupplier;
  final Map<String, List<TimeBlock>> Function(List<TimeBlock> timeBlocks) groupByFunction;
  final num Function(List<TimeBlock> timeBlocks) numReducer;

  const PieStatsCard({
    super.key,
    required this.tbs,
    required this.groupByFunction,
    required this.keyColorsSupplier,
    required this.numReducer,
  });

  @override
  State<PieStatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<PieStatsCard> {
  List<TimeBlock> get _timeBlocks => widget.tbs;
  final Map<String, List<TimeBlock>> map = {};
  final List<PieConfig> configs = [];
  num sum = 0;

  @override
  void initState() {
    super.initState();

    map.addAll(widget.groupByFunction.call(_timeBlocks.whereToList((p0) => p0.isFocus)));

    var idx = 0;
    for (var key in map.keys) {
      var value = map[key]!;
      var res = widget.numReducer.call(value);
      var pieConfig = PieConfig(
        value: (res / 60).toInt(),
        title: key,
        extra: key,
        color: widget.keyColorsSupplier.call(key),
      );
      configs.add(pieConfig);
    }
    sum = configs.isEmpty ? 0 : configs.mapToList((e) => e.value).reduce((value, element) => value + element);
  }

  @override
  Widget build(BuildContext context) {
    if (configs.isEmpty) {
      return emptyWidget;
    }
    return FnPieChart(
      key: UniqueKey(),
      rxHolder: PieChartRxHolder(configs, sum.toInt()),
      onFilter: (List<PieConfig> pies) {},
    );
  }
}