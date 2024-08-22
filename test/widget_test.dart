// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/model/misc.dart';
import 'package:flutter_pasteboard/service/time_rule_misc.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_keys.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pasteboard/main.dart';

void main() {
  test("parseRule", () {
    var res = $parseRule("-25+5-25+5-25+5-25+5-25+5-25+25");
    print(res);
  });

  test("key set serial deserial", () {
    List<LogicalKeySet> list = [FnKeys.cmdEnter, FnKeys.cmdEsc, FnKeys.cmdM, FnKeys.cmdSlash];
    for (var value in list) {
      var wrapper = ShortCutWrapper.fromSet(value.toReadable(), value);
      var bool = wrapper.keySet == value;
      assert(bool, "序列化失败: ${wrapper.keySet.toReadable()} !=${value.toReadable()}");
    }
  });
  test('测试 max 方法', () {
    List<int> testList = [1, 3, 2, 5, 4];
    int? result = testList.maxByMapper((item) => item);
    expect(result, 5);
    List<String> testStringList = ["a", "abc", "ab"];
    String? longestString = testStringList.maxByMapper((item) => item.length);
    expect(longestString, "abc");
  });
}
