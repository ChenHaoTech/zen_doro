import 'package:daily_extensions/daily_extensions.dart';

abstract class TagUtils {
  static final RegExp tagRegExp = RegExp(r"#([\u4e00-\u9fa5\w]+)", caseSensitive: false);

  static List<String> parseTags(String source) {
    Iterable<RegExpMatch> matches = tagRegExp.allMatches(source);
    return matches.map((match) => match.group(0)!.remove("#")).toList();
  }
}
