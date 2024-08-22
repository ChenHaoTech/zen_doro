import 'package:daily_extensions/daily_extensions.dart';
import 'package:extended_text_library/extended_text_library.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';

class TagText extends SpecialText {
  TagText(TextStyle? textStyle, SpecialTextGestureTapCallback? onTap, {this.showAtBackground = false, required this.start})
      : super(flag, ' ', textStyle, onTap: onTap);
  static const String flag = '#';
  final int start;

  /// whether show background for @somebody
  final bool showAtBackground;

  @override
  InlineSpan finishText() {
    final String atText = toString();
    var value = atText.remove("#").trim();
    var tag = TagStore.find.value2tag[value];

    var color = (tag?.color ?? Colors.blue).withOpacity(0.3);
    // return ExtendedWidgetSpan(
    //   start: start,
    //   actualText: atText,
    //   child: Chip(
    //     label: Text(value),
    //     elevation: 1,
    //     padding: EdgeInsets.zero,
    //     backgroundColor: color,
    //   ),
    //   alignment: PlaceholderAlignment.middle,
    //   deleteAll: true,
    // );
    var background = Paint()..color = color;
    return SpecialTextSpan(
      text: value,
      actualText: atText,
      start: start,
      style: this.textStyle?.copyWith(
            // backgroundColor: (tag?.color ?? Colors.blue).withOpacity(.3),
            background: background,
          ),
      recognizer: onTap == null
          ? null
          : (TapGestureRecognizer()
            ..onTap = () {
              onTap!(atText);
            }),
    );
  }
}
