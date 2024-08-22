import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/theme/theme.dart';

class EmotionStatsCard extends StatefulWidget {
  final List<TimeBlock> tbs;

  const EmotionStatsCard({super.key, required this.tbs});

  @override
  State<EmotionStatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<EmotionStatsCard> {
  List<TimeBlock> get _timeBlocks => widget.tbs;

  @override
  void initState() {
    super.initState();
    var timeBlocks = _timeBlocks;
  }

  @override
  Widget build(BuildContext context) {
    return emptyWidget;
  }
}