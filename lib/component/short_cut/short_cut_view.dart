import 'package:flutter/cupertino.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/theme/text_theme.dart';
import 'package:flutter_pasteboard/theme/theme.dart';

class ShortcutTextWidget extends StatelessWidget {
  final String text;
  final LogicalKeySet keySet;

  const ShortcutTextWidget(
    this.text, {
    super.key,
    required this.keySet,
  });

  @override
  Widget build(BuildContext context) {
    var tips = keySet.toReadable();
    return RawTipsTextWidget(text, tips: tips);
  }
}

class RawTipsTextWidget extends StatelessWidget {
  const RawTipsTextWidget(
    this.text, {
    super.key,
    required this.tips,
  });

  final String text;
  final String tips;

  @override
  Widget build(BuildContext context) {
    var textWidget = Text(
      text,
      style: context.defaultTextStyle.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
    if (PlatformUtils.isMobile) {
      return textWidget;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        textWidget,
        SizedBox(width: 8.0), // Space between the texts
        Text(
          tips,
          style: context.defaultTextStyle.withOpacity(.6),
        ),
      ],
    );
  }
}
