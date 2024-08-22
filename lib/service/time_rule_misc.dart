import 'dart:math';

import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/model/misc.dart';
import 'package:flutter_pasteboard/model/model_share.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:get/get.dart';

List<String> $parseRule(String rule) {
  throw "deprecated";
  return [""];
}

class TimeRuleController extends GetxController {
  static TimeRuleController get find => Get.find();

  SettingService get _settingService => SettingService.instance;

  PomodoroPattern get pattern => PomodoroPattern.fromJson(_settingService.promodoProfile.justValue.toSafeJson());

  List<PomodoroUnit> get _curSession => pattern.units;

  void updateCurSession(PomodoroPattern pattern) {
    var originV = _settingService.promodoProfile.justValue;

    if (pattern.toJsonStr() != originV) {
      //todo 测试 是否成功
      _settingService.promodoProfile.value = pattern.toJsonStr();
    }
  }

  final RxInt _idxRx = RxInt(0);

  int get idx => _idxRx.value;

  void reset() {
    _idxRx.value = 0;
  }

  PomodoroUnit next() {
    _idxRx.value = _idxRx.justValue + 1;
    this.log.dd(() => "update time rule ,idx:${_idxRx.justValue}");
    return getCurPomodoroUnit();
  }

  PomodoroUnit pre() {
    _idxRx.value = min(_idxRx.justValue - 1, 0);
    this.log.dd(() => "update time rule ,idx:${_idxRx.justValue}");
    return getCurPomodoroUnit();
  }

  PomodoroUnit getCurPomodoroUnit() {
    return _curSession[_idxRx.value % _curSession.length];
  }

  PomodoroUnit nextCurPomodoroUnit() {
    return _curSession[(_idxRx.value + 1) % _curSession.length];
  }

  PomodoroUnit ensureRest({
    bool next = false,
  }) {
    var ensure = _ensure((unit) => TimeBlockType.REST.match(unit.timeBlockType), next);
    if (ensure == null) {
      this.log.e("找不到 rest 的 unit, ${_curSession}");
    }
    return ensure ?? PomodoroUnit.buildFocus(minus: SettingService.instance.defaultFocusMinus.value);
  }

  PomodoroUnit ensureFocus({
    bool next = false,
  }) {
    var ensure = _ensure((unit) => TimeBlockType.FOCUS.match(unit.timeBlockType), next);
    if (ensure == null) {
      this.log.e("找不到 focus 的 unit, ${_curSession}");
    }
    return ensure ?? PomodoroUnit.buildRest(minus: SettingService.instance.defaultRestMinus.value);
  }

  //todo 测试
  PomodoroUnit? _ensure(bool Function(PomodoroUnit unit) predict, [bool next = false]) {
    var curSession = _curSession;
    fnassert(() => curSession.length > 1, curSession);
    for (int i = _idxRx.justValue; i < curSession.length + _idxRx.justValue; i++) {
      var unit = _curSession[i % _curSession.length];
      if (predict.call(unit)) {
        if (next) _idxRx.value = i;
        return unit;
      }
    }
    return null;
  }
}
