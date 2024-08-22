import 'dart:convert';

import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:get/get.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class HotKeyWrapper {
  final HotKey? originKey;
  late final Rx<HotKey?> _rxHotKey = Rx(originKey);
  final Function(bool isInit, HotKey? originhotKey, HotKey? hotKey) hotKeyBinder;
  final SettingHolder<String> settingHolder;
  static final _emptyFlag = "empty";

  HotKeyWrapper({
    required this.hotKeyBinder,
    required this.originKey,
    required this.settingHolder,
  });

  Future init() async {
    await settingHolder.init;
    var value = settingHolder.value;
    if (value == _emptyFlag) {
      _rxHotKey.value = null;
    } else if (!value.isEmptyOrNull) {
      try {
        var json = jsonDecode(value);
        _rxHotKey.value = HotKey.fromJson(json);
      } catch (e) {
        this.log.e("parse hotkey fail, ${e.runtimeType}", e);
        _rxHotKey.value = originKey;
        return;
      }
    }
    hotKeyBinder.call(true, _rxHotKey.lastValue, _rxHotKey.justValue);
  }

  HotKey? get hotkey => _rxHotKey.value;

  set hotkey(HotKey? value) {
    _rxHotKey.value = value;
    settingHolder.value = value?.toJsonStr() ?? _emptyFlag;
    hotKeyBinder.call(false, _rxHotKey.lastValue, _rxHotKey.value);
  }
}
