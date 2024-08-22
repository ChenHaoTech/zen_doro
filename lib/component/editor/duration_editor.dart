import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

class DurationEditor extends StatefulWidget {
  final Duration init;
  final void Function()? onEditComplete;
  final void Function(Duration duration) onChange;
  final bool Function(Duration duration)? preCheck;
  final FocusNode? focusNode;
  final bool autofocus;

  const DurationEditor({
    super.key,
    required this.init,
    this.onEditComplete,
    required this.onChange,
    this.preCheck,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<DurationEditor> createState() => DurationEditorState();
}

class DurationEditorState extends State<DurationEditor> {
  late final tec = TextEditingController(
    text: widget.init.inMinutes.toString(),
  );

  void updateDuration(Duration duration) {
    var string = duration.inMinutes.toString();
    if (tec.text != string) tec.text = string;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: tec,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        border: InputBorder.none,
        suffix: Text("min"),
      ),
      onEditingComplete: () => widget.onEditComplete?.call(),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        FilteringTextInputFormatter.singleLineFormatter,
        TextInputFormatter.withFunction((oldValue, newValue) {
          var text = newValue.text;
          if (text.isEmpty) {
            return newValue.copyWith(text: "");
          }
          var num = int.tryParse(text);
          if (num == null || num < 0 || num > 24 * 60) {
            return newValue;
          }
          var duration = (num * 60).seconds;
          if (widget.preCheck != null && !widget.preCheck!.call(duration)) {
            return oldValue;
          }
          widget.onChange.call(duration);
          return newValue;
        })
      ],
    ).intrinsicWidth().focus(onFocusChange: (focus) {
      if (focus) tec.selectAll();
    });
  }
}
