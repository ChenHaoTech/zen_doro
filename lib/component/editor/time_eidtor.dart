import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/misc/debounce.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ui_extension/ui_extension.dart';

class TimeEditorDemo extends StatefulWidget {
  const TimeEditorDemo({super.key});

  @override
  State<TimeEditorDemo> createState() => _TimeEditorDemoState();
}

class _TimeEditorDemoState extends State<TimeEditorDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TimeEditor(
        initTime: DateTime.now(),
        onUpdate: (TimeOfDay timeOfDay) {},
      ).center(),
    );
  }
}

//showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(DateTime.now()));
class TimeEditor extends StatefulWidget {
  final DateTime initTime;
  final DateTime? maxTime;
  final DateTime? minTime;
  final Function(TimeOfDay timeOfDay) onUpdate;
  final FocusNode? focusNode;
  final Function()? onEditingComplete;
  final bool autofocus;
  final bool enable;

  TimeEditor({
    super.key,
    required this.initTime,
    required this.onUpdate,
    this.onEditingComplete,
    this.focusNode,
    this.autofocus = false,
    this.enable = true,
    this.maxTime,
    this.minTime,
  });

  @override
  State<TimeEditor> createState() => TimeEditorState();
}

class TimeEditorState extends State<TimeEditor> {
  final mmFormate = DateFormat('mm');
  final HHFormate = DateFormat('HH');
  late int hour = int.parse(HHFormate.format(widget.initTime));
  late int minute = int.parse(mmFormate.format(widget.initTime));
  late final FocusNode _hourFocusNode = widget.focusNode ?? FocusNode();
  late final FocusNode _minutFocusNode = FocusNode();
  late final hourTec = TextEditingController(text: hour.padLeft(2, "0").toString());
  late final minuteTec = TextEditingController(text: minute.padLeft(2, "0").toString());

  void updateTime({int? hour, int? minute}) {
    var hourPadLeft = (hour ?? this.hour).padLeft(2, "0");
    var minutePadLeft = (minute ?? this.minute).padLeft(2, "0");
    if (hourPadLeft != hourTec.text) hourTec.text = hourPadLeft;
    if (minutePadLeft != minuteTec.text) minuteTec.text = minutePadLeft;
    _check(hour: hour, minute: minute);
  }

  void _notifyChange({bool updateTec = false}) {
    if (updateTec) {
      hourTec.text = hour.padLeft(2, "0");
      minuteTec.text = minute.padLeft(2, "0");
    }
    _check(hour: hour, minute: minute);
    DebounceUtils.debounce(this.debugKey, 1.milliseconds, () {
      var td = TimeOfDay(hour: hour, minute: minute);
      var result = widget.initTime.copyWithTd(td);
      if (widget.maxTime != null && widget.maxTime!.isBefore(result)) return;
      if (widget.minTime != null && widget.minTime!.isAfter(result)) return;

      widget.onUpdate.call(td);
    });
  }

  void _onError(dynamic e) {
    // FnNotification.toast("格式非法 %s".i18n.fill([e]));
  }

  bool? error;

  bool _check({int? hour, int? minute}) {
    var time = widget.initTime.copyWithTd(TimeOfDay(hour: hour ?? this.hour, minute: minute ?? this.minute));
    var flag = true;
    if (widget.maxTime != null) {
      flag &= widget.maxTime!.isAfter(time) || widget.maxTime == time;
    }
    if (widget.minTime != null) {
      flag &= widget.minTime!.isBefore(time) || widget.minTime == time;
    }
    // DebugUtils.log("time_eidtor:101 ${flag}, ${error} \n${StackTrace.current}");
    if (error != !flag) {
      setState(() {
        error = !flag;
      });
    }
    return flag;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextField(
          onTap: () {
            if (_hourFocusNode.hasPrimaryFocus) {
              _showTimePicker();
            } else {
              _hourFocusNode.requestFocus();
            }
          },
          readOnly: !widget.enable,
          autofocus: widget.autofocus,
          focusNode: _hourFocusNode,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hour.toString(),
            isDense: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            FilteringTextInputFormatter.singleLineFormatter,
            TextInputFormatter.withFunction((oldValue, newValue) {
              try {
                if (newValue.text.isEmptyOrNull) return newValue;
                // DebugUtils.log("time_eidtor:110 ${newValue.text}\n${StackTrace.current}");
                var parseLoose = HHFormate.parseStrict(newValue.text);
                hour = parseLoose.hour;
                if (newValue.text.length >= 2) _minutFocusNode.requestFocus();
                _notifyChange();
              } catch (e) {
                _onError(e);
                return oldValue;
              }
              return newValue;
            })
          ],
          controller: hourTec,
        ).intrinsicWidth().focus(onFocusChange: (focus) {
          if (focus) hourTec.selectAll();
        }),
        Text(":"),
        TextField(
          onTap: () {
            if (_minutFocusNode.hasPrimaryFocus) {
              _showTimePicker();
            } else {
              _minutFocusNode.requestFocus();
            }
          },
          readOnly: !widget.enable,
          focusNode: _minutFocusNode,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: minute.toString(),
            isDense: true,
          ),
          controller: minuteTec,
          onEditingComplete: widget.onEditingComplete,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            FilteringTextInputFormatter.singleLineFormatter,
            TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.isEmptyOrNull) return newValue;
              try {
                var parseLoose = mmFormate.parseStrict(newValue.text);
                minute = parseLoose.minute;
                if (newValue.text.length >= 2) {
                  runOnNextFrame(() => widget.onEditingComplete?.call());
                }
                _notifyChange();
              } catch (e) {
                _onError(e);
                return oldValue;
              }
              return newValue;
            })
          ],
        ).intrinsicWidth().focus(onFocusChange: (focus) {
          if (focus) minuteTec.selectAll();
        }),
      ],
      mainAxisSize: MainAxisSize.min,
    )
        .container(
          decoration: error == true
              ? BoxDecoration(
                  border: Border.all(color: Colors.red), // 所有四边的边框颜色
                )
              : null,
        )
        .easyTap(onTap: () {
          _showTimePicker();
        })
        .ignorePointer(ignoring: !widget.enable)
        .opacity(widget.enable ? 1 : .3);
  }

  Future<void> _showTimePicker() async {
    var timeOfDay = await showTimePicker(context: context, initialTime: TimeOfDay(hour: hour, minute: minute));
    hour = timeOfDay?.hour ?? hour;
    minute = timeOfDay?.minute ?? minute;
    _notifyChange(updateTec: true);
  }
}
