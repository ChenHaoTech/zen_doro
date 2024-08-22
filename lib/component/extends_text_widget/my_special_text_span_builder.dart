import 'package:extended_text_library/extended_text_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/component/extends_text_widget/fn_text.dart';

class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  MySpecialTextSpanBuilder({this.onTagTap, this.textStyle, this.showAtBackground = false});

  final TextStyle? textStyle;
  final Function(dynamic tagValue)? onTagTap;

  /// whether show background for @somebody
  final bool showAtBackground;

  @override
  TextSpan build(String data, {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap}) {
    var res = super.build(data, textStyle: textStyle, onTap: onTap);
    //todo 保留最近的 builder 内容
    return res;
  }

  @override
  SpecialText? createSpecialText(String flag, {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap, int? index}) {
    if (flag == '') {
      return null;
    }
    if (isStart(flag, TagText.flag)) {
      return TagText(
        textStyle,
        onTagTap ?? onTap,
        start: index! - (TagText.flag.length - 1),
        showAtBackground: showAtBackground,
      );
    }
    return null;
  }
}
