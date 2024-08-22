import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/theme/text_theme.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:ui_extension/ui_extension.dart';

class FnTextBtn extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? color;
  final bool autofocus;

  static Widget simple({
    required Function onPressed,
    required String text,
    TextStyle? style,
  }) {
    return Builder(builder: (context) {
      return Text(
        text,
        style: style ?? context.defaultTextStyle.withColor(context.primary),
      ).inkWell(onTap: () => onPressed.call());
    });
  }

  const FnTextBtn({
    Key? key,
    this.onPressed,
    required this.text,
    this.autofocus = false,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      autofocus: autofocus,
      child: Text(
        text,
        style: context.defaultTextStyle.copyWith(color: color ?? context.primary),
      ),
    );
  }
}
