import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/week_view/src/utils/builders.dart';
import 'package:flutter_pasteboard/component/week_view/src/utils/utils.dart';
import 'package:flutter_pasteboard/component/week_view/src/widgets/day_view.dart';

/// Builds an event text widget.
typedef EventTextBuilder = Widget Function(FlutterWeekViewEvent event, BuildContext context, DayView dayView, double height, double width);

/// Represents a flutter week view event.
class FlutterWeekViewEvent implements Comparable<FlutterWeekViewEvent> {
  /// The event title.
  final String title;

  /// The event description.
  final String description;

  /// The event start date & time.
  DateTime start;

  /// The event end date & time.
  DateTime end;

  /// The event widget background color.
  final Color? backgroundColor;

  /// The event widget decoration.
  final BoxDecoration? decoration;

  /// The event text widget text style.
  final TextStyle? textStyle;

  /// The event widget padding.
  final EdgeInsets? padding;

  /// The event widget margin.
  final EdgeInsets? margin;

  /// The event widget tap event.

  /// The event text builder.
  final EventTextBuilder? eventTextBuilder;
  final dynamic extra;

  /// Creates a new flutter week view event instance.
  FlutterWeekViewEvent({
    required this.title,
    required this.description,
    required DateTime start,
    required DateTime end,
    this.backgroundColor = const Color(0xCC2196F3),
    this.decoration,
    this.textStyle = const TextStyle(color: Colors.white),
    this.padding = const EdgeInsets.all(10),
    this.margin,
    this.eventTextBuilder,
    this.extra,
  })  : start = start.yearMonthDayHourMinute,
        end = end.yearMonthDayHourMinute;

  /// Builds the event widget.
  Widget build(BuildContext context, DayView dayView, double height, double width) {
    height = height - (padding?.top ?? 0.0) - (padding?.bottom ?? 0.0);
    width = width - (padding?.left ?? 0.0) - (padding?.right ?? 0.0);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: decoration ?? (backgroundColor != null ? BoxDecoration(color: backgroundColor) : null),
        margin: margin,
        padding: padding,
        child: (eventTextBuilder ?? DefaultBuilders.defaultEventTextBuilder)(
          this,
          context,
          dayView,
          math.max(0.0, height),
          math.max(0.0, width),
        ),
      ),
    );
  }

  /// Shifts the start and end times, so that the event's duration is unaltered
  /// and the event now starts in [newStartTime].
  void shiftEventTo(DateTime newStartTime) {
    end = end.add(newStartTime.difference(start));
    start = newStartTime;
  }

  @override
  int compareTo(FlutterWeekViewEvent other) {
    int result = start.compareTo(other.start);
    if (result != 0) {
      return result;
    }
    return end.compareTo(other.end);
  }
}
