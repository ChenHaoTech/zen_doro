import 'dart:math';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';

import 'progressive_time_picker.dart';

class FnTimePicker extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Function(DateTime startTime)? onStartChange;
  final Function(Duration duration) onDurationChange;

  const FnTimePicker({
    super.key,
    required this.child,
    this.onStartChange,
    required this.onDurationChange,
    required this.duration,
  });

  @override
  State<FnTimePicker> createState() => FnTimePickerState();
}

extension PickedTimeExt on PickedTime {
  int get minus {
    return h * 60 + m;
  }

  PickedTime addDuration(Duration duration) {
    var hourForPickTime = (duration.inMinutes / 60) * 24;
    return PickedTime(h: this.h + hourForPickTime.toInt(), m: this.m + ((hourForPickTime % 1) * 60).toInt());
  }
}

class FnTimePickerState extends State<FnTimePicker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ClockTimeFormat _clockTimeFormat = ClockTimeFormat.twentyFourHours;
  ClockIncrementTimeFormat _clockIncrementTimeFormat = ClockIncrementTimeFormat.fiveMin;
  final int DAY_MINUS = 24 * 60;
  final int minusPerRotate = 60;

  double _computePercent(PickedTime begin, PickedTime end) {
    return ((end.minus + DAY_MINUS - begin.minus) % DAY_MINUS) / DAY_MINUS;
  }

  bool _checkStartTime(PickedTime start) {
    var time = start.h * 60 + start.m;
    return (time <= 23 * 60 + 59 && time >= 12 * 60) || time == 0;
  }

  bool _checkStartTimeLatter(PickedTime start) {
    var time = start.h * 60 + start.m;
    return (time > 0 && time < 12 * 60);
  }

  late Duration _duration = widget.duration;

  late PickedTime _startTime = PickedTime(h: 0, m: 0);
  late PickedTime _endTime = _startTime.addDuration(_duration);

  void updateTime(Duration duration) {
    if (!mounted) return;
    _duration = duration;
    _endTime = _startTime.addDuration(duration);
    setState(() {});
  }

  bool? validRange = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTimePicker();
  }

  Color get primary => context.primary;

  Color get primaryContainer => context.cs.primaryContainer;

  Widget _buildTimePicker() {
    return LayoutBuilder(builder: (context, constrict) {
      var size = min(constrict.maxWidth, constrict.maxHeight);
      return TimePicker(
        initTime: _startTime,
        endTime: _endTime,
        // disabledRange: DisabledRange(
        //   initTime: _disabledInitTime,
        //   endTime: _disabledEndTime,
        //   disabledRangeColor: context.cs.error.blend(context.cs.onBackground),
        //   errorColor: context.cs.error,
        // ),
        height: size,
        width: size,
        onSelectionChange: _updateLabels,
        onSelectionEnd: (start, end, isDisableRange) =>
            print('onSelectionEnd => init : ${start.h}:${start.m}, end : ${end.h}:${end.m}, isDisableRange: $isDisableRange'),
        primarySectors: _clockTimeFormat.value,
        secondarySectors: _clockTimeFormat.value * 2,
        decoration: TimePickerDecoration(
          baseColor: context.cs.background.blend(context.cs.primary),
          pickerBaseCirclePadding: 15.0,
          sweepDecoration: TimePickerSweepDecoration(
            pickerStrokeWidth: 30.0,
            pickerColor: context.cs.primaryContainer,
            showConnector: true,
          ),
          initHandlerDecoration: TimePickerHandlerDecoration(
            color: primaryContainer,
            shape: BoxShape.circle,
            radius: 12.0,
            icon: Icon(
              Icons.not_started_outlined,
              size: 20.0,
              color: primary,
            ),
          ),
          endHandlerDecoration: TimePickerHandlerDecoration(
            color: primaryContainer,
            shape: BoxShape.circle,
            radius: 12.0,
            icon: Icon(
              Icons.notifications_active_outlined,
              size: 20.0,
              color: primary,
            ),
          ),
          primarySectorsDecoration: TimePickerSectorDecoration(
            color: context.background,
            width: 1.0,
            size: 4.0,
            radiusPadding: 25.0,
          ),
          secondarySectorsDecoration: TimePickerSectorDecoration(
            color: primary,
            width: 1.0,
            size: 2.0,
            radiusPadding: 25.0,
          ),
          clockNumberDecoration: TimePickerClockNumberDecoration(
            defaultTextColor: context.primary,
            defaultFontSize: 12.0,
            scaleFactor: 2.0,
            showNumberIndicators: false,
            clockTimeFormat: _clockTimeFormat,
            clockIncrementTimeFormat: _clockIncrementTimeFormat,
          ),
        ),
        child: widget.child,
      );
    });
  }

  Widget _buildDebugWidget() {
    return Text(_computePercent(_startTime, _endTime).toString());
  }

  void _updateLabels(PickedTime start, PickedTime end, bool? isDisableRange) {
    print('_updateLabels => init : ${start.h}:${start.m}, end : ${end.h}:${end.m}, isDisableRange: $isDisableRange');
    if (_checkStartTimeLatter(start)) {
      setState(() {
        var percent = _computePercent(_startTime, _endTime);
        var minus = (percent * DAY_MINUS).toInt();
        // _startTime = PickedTime(h: 0, m: 0);
        _endTime = PickedTime(h: (minus / 60).toInt(), m: minus % 60);
      });
      return;
    }

    setState(() {
      // _startTime = start;
      _endTime = end;
      _duration = (_computePercent(_startTime, _endTime) * minusPerRotate).minutes;
      widget.onDurationChange.call(_duration);

      var offsetDuration = (_computePercent(_startTime, PickedTime(h: 0, m: 0)) * minusPerRotate).minutes;
      if (offsetDuration.inSeconds > 10) {
        var starTime = DateTime.now().subtract(offsetDuration);
        widget.onStartChange?.call(starTime);
      }
      validRange = isDisableRange;
    });
  }
}
