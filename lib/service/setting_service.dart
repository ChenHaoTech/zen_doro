import 'dart:async';

import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/fn_platform_utils.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/model/misc.dart';
import 'package:flutter_pasteboard/service/data_change_listener.dart';
import 'package:flutter_pasteboard/service/drift/database.dart';
import 'package:flutter_pasteboard/service/drift/drift_adapter.dart';
import 'package:get/get.dart';

class SettingHolder<T> {
  final Completer _completer = Completer();
  final String key;

  Future get init => _completer.future;

  final RxObjectMixin<T> rx;

  SettingHolder(this.rx, this.key);

  T get value => rx.value;

  T get justValue => rx.justValue;

  set value(T data) => rx.value = data;

  void set(T value) {
    this.value = value;
  }

  set justValue(T data) => rx.justValue = data;

  void refresh() {
    rx.refresh();
  }

  //toString
  @override
  String toString() {
    return 'SettingHolder{rx: $rx}';
  }
}

abstract class SettingConst {
  static String common = PomodoroPattern(
      uuid: "PomodoroPattern_common",
      units: [
        PomodoroUnit.buildFocus(minus: 25),
        PomodoroUnit.buildRest(minus: 5),
        PomodoroUnit.buildFocus(minus: 25),
        PomodoroUnit.buildRest(minus: 5),
        PomodoroUnit.buildFocus(minus: 25),
        PomodoroUnit.buildRest(minus: 5),
        PomodoroUnit.buildFocus(minus: 25),
        PomodoroUnit.buildRest(minus: 5),
      ],
      desc: "Common".i18n,
      extra: {}).toJsonStr();
  static String debug = PomodoroPattern(
      uuid: "PomodoroPattern_debug",
      units: [
        PomodoroUnit.buildFocus(minus: 1),
        PomodoroUnit.buildRest(minus: 2),
        PomodoroUnit.buildFocus(minus: 3),
        PomodoroUnit.buildRest(minus: 4),
        PomodoroUnit.buildFocus(minus: 5),
        PomodoroUnit.buildRest(minus: 6),
        PomodoroUnit.buildFocus(minus: 7),
        PomodoroUnit.buildRest(minus: 8),
      ],
      desc: "Debug".i18n,
      extra: {}).toJsonStr();
  static String progressive = PomodoroPattern(
      uuid: "PomodoroPattern_progressive",
      units: [
        PomodoroUnit.buildFocus(minus: 5),
        PomodoroUnit.buildRest(minus: 2),
        PomodoroUnit.buildFocus(minus: 15),
        PomodoroUnit.buildRest(minus: 3),
        PomodoroUnit.buildFocus(minus: 25),
        PomodoroUnit.buildRest(minus: 5),
        PomodoroUnit.buildFocus(minus: 60),
        PomodoroUnit.buildRest(minus: 25),
      ],
      desc: "Progressive".i18n,
      extra: {}).toJsonStr();
  static String custom_temp = PomodoroPattern(
      uuid: "PomodoroPattern_custome",
      units: [
        PomodoroUnit.buildFocus(minus: 25),
        PomodoroUnit.buildRest(minus: 5),
        PomodoroUnit.buildFocus(minus: 25),
        PomodoroUnit.buildRest(minus: 5),
        PomodoroUnit.buildFocus(minus: 25),
        PomodoroUnit.buildRest(minus: 5),
        PomodoroUnit.buildFocus(minus: 25),
        PomodoroUnit.buildRest(minus: 5),
      ],
      desc: "Custom".i18n,
      extra: {}).toJsonStr();
}

class SettingService extends GetxController implements SettingChangeListener {
  static SettingService get instance => Get.touch(() => SettingService());

  // 超时提醒, 每超过5分钟, 会提醒一次
  late final SettingHolder<int> overtimeReminder = _build(
    "overtimeReminder",
    Rx<int>(5),
    title: "超时提醒时间(单位分钟)".i18n,
    description: "每超时专注/休息的时间超过指定的分钟数，会提醒一次".i18n,
  );

  late final SettingHolder<int> smallestLifeOfTask = _build(
    "smallestLifeOfTask",
    Rx<int>(1),
    title: "最小专注时间(单位分钟)".i18n,
    description: "少于对应的时间不计入计算".i18n,
    // icon: Icons.timer_outlined,
  );

  //bigestLifeOfRest 最大休息时间, 单位分钟, 初始25
  late final SettingHolder<int> biggestLifeOfRest = _build(
    "biggestLifeOfRest",
    Rx<int>(25),
    title: "最大休息时间(单位分钟)".i18n,
    description: "最多进行休息的时间".i18n,
    // icon: Icons.timer_outlined,
  );

  late final SettingHolder<int> sessionResumptionTime = _build(
    "SessionResumptionTime",
    Rx<int>(15),
    title: "退出保护时长".i18n,
    description: "如果退出app超过指定的xx分钟，您的番茄时钟将不会重新计入当前的专注时段".i18n,
  );

  late final SettingHolder<double> dashboardFactor = _build("dashboardFactor", Rx<double>(3 / 5));

  late final SettingHolder<int> smallestLifeOfRest = _build(
    "smallestLifeOfRest",
    Rx<int>(1),
    title: "最小休息时间(单位分钟)".i18n,
    description: "最少进行休息的时间".i18n,
    // icon: Icons.timer_outlined,
  );

  late final SettingHolder<bool> autoRest = _build(
    "autoRest",
    Rx<bool>(true),
    title: "Auto Rest".i18n,
    description: "专注后自动开始休息".i18n,
    icon: Icons.settings_backup_restore_outlined,
  );

  late final SettingHolder<int> smartRestFactor = _build(
    "smartrestfactor",
    Rx<int>(5),
    title: "休息时间计算因子".i18n,
    description: "休息时间=累计专注时间除去对应的值, 例如: 专注25分钟, 休息 (25/%s) 分钟".i18n,
    icon: Icons.timelapse_rounded,
  );

  late final SettingHolder<bool> autoFocus = _build(
    "autoFocus",
    Rx<bool>(false),
    title: "Auto Focus".i18n,
    description: "休息后自动开始专注".i18n,
    icon: Icons.center_focus_weak,
  );

  late final SettingHolder<bool> needGuideInTimeLine = _build(
    "needGuideInTimeLine",
    Rx<bool>(true),
  );

  late final SettingHolder<int> promodoEndAction = _build(
    "pomodoroEndAction",
    Rx<int>(0),
    enableView: !PlatformUtils.isDesktop,
    title: "专注/休息后的窗口行为".i18n,
    description: "配置每次专注/休息后的窗口行为".i18n,
    type: SettingType.custom,
  );

  late final SettingHolder<bool> canNotify = _build(
    "can_notify_flag",
    Rx<bool>(true),
    enableView: !PlatformUtils.isWeb,
    title: "是否通知".i18n,
    description: "配置每次专注/休息后是否通知".i18n,
  );

  late final SettingHolder<bool> endFeedbackShowTime = _build(
    "end_feedback_show_time",
    Rx<bool>(true),
  );

  late final SettingHolder<String> promodoProfile = _build(
    "pomodoroProfile",
    Rx<String>(SettingConst.common),
    title: "Pomodoro Profile".i18n,
    description: "Profile for Pomodoro settings".i18n,
    type: SettingType.custom,
  );

  late final SettingHolder<int> defaultFocusMinus = _build(
    "defaultTimeBlockDurationInMinus",
    Rx<int>(25),
    title: "Default Focus Minutes".i18n,
    description: "Default duration for focus periods in minutes".i18n,
  );

  late final SettingHolder<int> defaultRestMinus = _build(
    "defaultRestTimeBlockDurationInMinus",
    Rx<int>(5),
    title: "Default Rest Minutes".i18n,
    description: "Default duration for rest periods in minutes".i18n,
  );

  late final SettingHolder<String> audioConfig = _build(
    "audioConfig",
    Rx<String>(""),
  );

  late final SettingHolder<bool> audioMute = _build(
    "audioMute",
    Rx<bool>(true),
    title: "Audio Mute".i18n,
    description: "Enable or disable audio mute".i18n,
  );

  late final SettingHolder<String> lastTask = _build(
    "lastTask",
    Rx<String>(""),
  );

  late final SettingHolder<double> weekvieScale = _build(
    "weekvieScale",
    Rx<double>(.5),
  );

  late final SettingHolder<String> windowHotKey = _build(
    "windowHotKey",
    Rx<String>(""),
    title: "Window Hot Key".i18n,
    description: "Hot key for window operations".i18n,
    type: SettingType.shortcut,
  );

  late final SettingHolder<String> windowTopHotKey = _build(
    "windowTopHotKey",
    Rx<String>(""),
    title: "窗口置顶".i18n,
    description: "窗口置顶切换快捷键".i18n,
    type: SettingType.shortcut,
  );

  late final SettingHolder<String> mixsList = _build(
    "audio_mixs_list",
    Rx<String>(""),
  );

  late final SettingHolder<String> curMixs = _build(
    "cur_audio_mixs",
    Rx<String>(""),
  );

  late final SettingHolder<int> settingIdx = _build(
    "settingIdx",
    Rx<int>(0),
  );
  late final SettingHolder<bool> showComputeRestTips = _build("show_compute_rest_tips", RxBool(true));

  final Map<String, SettingHolder> values = {};
  final Map<String, SettingItem> configs = {};
  final Map<String, IconData> iconDatas = {};

  Map<String, dynamic> toJson() {
    return values.map((key, value) => MapEntry(key, value.justValue));
  }

  // todo 读写测试
  SettingHolder<T> _build<T>(
    String key,
    RxObjectMixin<T> rx, {
    T Function(String)? deserialize,
    String Function(T)? serialize,
    String? title,
    bool enableView = true,
    String? description,
    String? groupTitle,
    SettingType? type,
    IconData? icon,
    List<String>? tags,
  }) {
    if (deserialize == null) {
      if (rx.justValue is int) {
        deserialize = (str) => int.parse(str) as T;
        serialize = (value) => value.toString();
      }
      if (rx.justValue is bool) {
        deserialize = (str) => bool.parse(str) as T;
        serialize = (value) => value.toString();
      }
      if (rx.justValue is double) {
        deserialize = (str) => double.parse(str) as T;
        serialize = (value) => value.toString();
      }
      if (rx.justValue is String) {
        deserialize = (str) => str as T;
        serialize = (value) => value.toString();
      }
    }
    fnassert(() => !values.containsKey(key));
    fnassert(() => !configs.containsKey(key));
    fnassert(() => !iconDatas.containsKey(key));

    SettingHolder<T> res = values.putIfAbsent(key, () => SettingHolder<T>(rx, key)) as SettingHolder<T>;

    if (icon != null) {
      iconDatas.putIfAbsent(key, () => icon);
    }
    //bind item
    if (title != null && enableView) {
      configs.putIfAbsent(
          key,
          () => SettingItem.fromSettingHolder(
                res,
                title: title,
                description: description,
                groupTitle: groupTitle,
                type: type,
                tags: tags,
              ));
    }

    // logic
    _valueChanger.putIfAbsent(key, () => ((val) => rx.value = val, () => rx.justValue));
    var query = AppDatabase.get.settingTb.select();
    query.where((tbl) => tbl.key.equals(key));
    var future = query.getSingleOrNull();
    future.then((value) {
      if (value != null) {
        res.accept(value, deserialize);
      }
      res._completer.tryComplete();
      rx.listen((p0) {
        var tbCompanion = res.toTbCompanion(serialize);
        AppDatabase.get.settingTb.insertOne(tbCompanion, mode: drift.InsertMode.insertOrReplace);
      }).bind(instance);
    });
    return res;
  }

  @override
  void onInit() {
    super.onInit();
    // touch init
    needGuideInTimeLine;
    // 正反写 init
    SettingChangeListener.listener.add(this);
  }

  static final Map<String, (void Function(dynamic value), dynamic Function() supplier)> _valueChanger = {};

  @override
  void onClose() {
    super.onClose();
    SettingChangeListener.listener.remove(this);
  }

  @override
  void whenSettingChange(String key, oldV, newV) {
    this.log.dd(() => "setting(${key}) change :${oldV}=>${newV}");
    // 已经相同了, 返回
    if (_valueChanger[key]!.$2.call() == newV) {
      return;
    }
    _valueChanger[key]!.$1.call(newV);
  }
}
