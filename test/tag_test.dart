import 'package:flutter_pasteboard/misc/tag_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tags', () {
    var parseTags = TagUtils.parseTags("slkdj #xkjc");
    print(parseTags);
    parseTags = TagUtils.parseTags("slkdj#xkjc");
    print(parseTags);
    parseTags = TagUtils.parseTags("#slkdj #xkjc");
    print(parseTags);
    parseTags = TagUtils.parseTags("slkdj\#xkjc赛框架");
    print(parseTags);
    parseTags = TagUtils.parseTags("美团开发 #工作 ");
    print(parseTags);
  });
}
