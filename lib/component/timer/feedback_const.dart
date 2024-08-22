import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/theme/theme.dart';
import 'package:get/get.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:ui_extension/ui_extension.dart';

final _feedbackEmojis = ["😭", "😢", "😐", "😀", "😍"].reversed.toList(growable: false);
final feedbackEmojis = ["😭", "😐", "😍"].reversed.toList(growable: false);
final unknow_feedbackEmoji = "🤔";
final feedbackEmojisColor = {
  "😭": Colors.blue,
  "😢": Colors.blueGrey,
  "😐": Colors.greenAccent,
  "😀": Colors.orange,
  "😍": Colors.redAccent,
};
final feedbackEmojisTips = {
  "😭": [
    "🚀 虽然有点挑战，但每次失败都是成功的垫脚石！下次会更好！".i18n,
    "🌪️ 状态有点低迷，但没关系，调整一下，下次重新出发！".i18n,
  ],
  "😐": [
    "🌱 表现还不错，下次可以更上一层楼哦！".i18n,
    "🌈 表现不错，但下次可以更专注一些，期待你的表现！".i18n,
  ],
  "😍": [
    "🌟 哇塞，你的表现简直棒极了！继续保持，专注力满分！".i18n,
    "🎉 你的专注力就像超级英雄一样，无人能敌！".i18n,
  ],
};
