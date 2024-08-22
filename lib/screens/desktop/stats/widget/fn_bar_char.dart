import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:ui_extension/ui_extension.dart';

class BarCharConfig {
  final List<(/*category*/ String, Color)> colors;

  final List<
      (
        /*title*/
        String,
        /*list by category*/ Map<String, double>
      )> datas;

  BarCharConfig({
    required this.colors,
    required this.datas,
  });
}

class FnBarChar extends StatefulWidget {
  final BarCharConfig config;
  final Widget Function(double value)? valueSupplier;

  FnBarChar({
    super.key,
    required this.config,
    this.valueSupplier,
  });

  @override
  State<FnBarChar> createState() => _FnBarCharState();
}

class _FnBarCharState extends State<FnBarChar> {
  final betweenSpace = 0.2;

  List<Color> get _colors => widget.config.colors.mapToList((i) => i.$2);

  List<String> get _label => widget.config.colors.mapToList((i) => i.$1);

  List<String> get _title => widget.config.datas.mapToList((i) => i.$1);

  late double _avg;

  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    List<double> score = widget.config.datas.mapToList((e) => e.$2).mapToList((e) => e.values.sum).toList();

    _avg = score.average;
  }

  Widget leftTitle(double value, TitleMeta meta) {
    if (value == meta.max || value == meta.min) return emptyWidget;
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: widget.valueSupplier?.call(value) ??
          Text(
            meta.formattedValue,
          ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text = _title.getNullable(value.toInt()) ?? "";
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    var barGroupDatas = _buildBarChartGroupData();
    var barChart = BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: leftTitle,
              reservedSize: 44,
              interval: 60,
            ),
          ),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: bottomTitles,
              interval: 2,
              reservedSize: 20,
            ),
          ),
        ),
        barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.blueGrey,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              tooltipHorizontalAlignment: FLHorizontalAlignment.right,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                var x = group.x;

                return BarTooltipItem(
                  '${_title[x]}${_label[rodIndex]}\n',
                  TextStyle(
                    color: context.background,
                    fontSize: 12,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: (rod.toY - rod.fromY).toInt().toString(),
                      style: TextStyle(
                        color: context.background, //widget.touchedBarColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
            touchCallback: (event, barTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions || barTouchResponse == null || barTouchResponse.spot == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
              });
            } /*,mouseCursorResolver: (event,response){
                return null;
              }*/
            ),
        borderData: FlBorderData(show: false),
        barGroups: barGroupDatas,
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              label: HorizontalLineLabel(labelResolver: (_) => "avg"),
              y: _avg,
              color: context.primary,
              strokeWidth: 1,
              dashArray: [20, 4],
            ),
          ],
        ),
      ),
    );
    return LayoutBuilder(builder: (context, c) {
      var sumWidth = barGroupDatas.sum((p0) => p0.width) * 2.0;
      if (sumWidth < c.maxWidth) {
        return barChart;
      } else {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: barChart.boxConstraints(maxWidth: sumWidth),
        );
      }
    });
    return barChart;
  }

  List<BarChartGroupData> _buildBarChartGroupData() {
    var datas = widget.config.datas;
    List<BarChartGroupData> res = [];
    for (var i = 0; i < datas.length; i++) {
      Map<String, double> data = datas[i].$2;
      List<double> scores = [];
      for (var pair in widget.config.colors) {
        var title = pair.$1;
        scores.add(data[title] ?? 0);
      }
      if (scores.isNotEmpty) res.add(generateGroupData(i, scores));
    }
    return res;
  }

  BarChartGroupData generateGroupData(
    int x,
    List<double> datas,
  ) {
    fnassert(() => !datas.isEmpty);
    List<BarChartRodData> rodDatas = [];
    for (var i = 1; i <= datas.length; i++) {
      double start = datas.sublist(0, i - 1).sum((p0) => p0) + betweenSpace * (datas.length - 1);
      double end = datas.sublist(0, i).sum((p0) => p0) + betweenSpace * (datas.length - 1);
      var barChartRodData = BarChartRodData(
        fromY: start,
        toY: end,
        borderRadius: BorderRadius.zero,
        color: _colors[i - 1],
        width: 20,
      );
      rodDatas.add(barChartRodData);
    }
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      barRods: rodDatas,
    );
  }
}
