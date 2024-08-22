import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';

class PieConfig<T> {
  final num value;
  final String title;
  final Function()? onTap;
  final Color color;
  final T extra;
  final RxBool? hover;

  PieConfig({
    required this.value,
    required this.extra,
    required this.title,
    required this.color,
    this.onTap,
    this.hover,
  });
}

class PieChartRxHolder extends GetxController {
  final List<PieConfig> all;
  late final int sum;

  PieChartRxHolder(this.all, this.sum);

  late final RxList<PieConfig> hides = RxList();
  late final RxList<PieConfig> shows = RxList(all);

  StreamSubscription? _sub;

  void init() {
    void build(List<PieConfig> hides) {
      shows.value = all.toList()..removeWhere((e) => hides.contains(e));
    }

    _sub?.cancel();
    _sub = hides.listen((p0) {
      build(p0);
    });
  }

  void dispose() {
    _sub?.cancel();
  }
}

class FnPieChart extends StatefulWidget {
  final PieChartRxHolder rxHolder;
  final Function(List<PieConfig> pies) onFilter;

  FnPieChart({
    super.key,
    required this.rxHolder,
    required this.onFilter,
  });

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<FnPieChart> with StateDisposeMixin {
  late final PieChartRxHolder controller = widget.rxHolder;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        var pieChart = PieChart(
          PieChartData(
            borderData: FlBorderData(
              show: false,
            ),
            sectionsSpace: 0,
            centerSpaceRadius: 40,
            sections: showingSections(),
          ),
        );
        return pieChart;
      },
    );
  }

  List<PieChartSectionData> showingSections() {
    var res = List.generate(controller.shows.length, (i) {
      var config = controller.shows[i];
      final isTouched = config.hover?.value ?? false;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      var shadows = [Shadow(color: context.cs.onBackground, blurRadius: 2)];
      return PieChartSectionData(
        badgeWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              config.title,
              style: TextStyle(
                fontSize: fontSize * .8,
                fontWeight: FontWeight.bold,
                color: context.cs.background,
                shadows: shadows,
              ),
            ),
            Text(
              '${(config.value / controller.sum * 100).toStringAsFixed(1)}%',
            ),
          ],
        ),
        badgePositionPercentageOffset: 1,
        color: config.color,
        value: config.value.toDouble(),
        radius: radius,
        title: config.title,
        showTitle: false,
      );
    });
    return res;
  }
}
