import 'dart:convert';

import 'package:daily_extensions/daily_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pasteboard/misc/download_utils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'misc.freezed.dart';
part 'misc.g.dart';

@freezed
class FeedBackInfo with _$FeedBackInfo {
  const factory FeedBackInfo({
    required String label,
    required String value,
  }) = _FeedBackInfo;

  factory FeedBackInfo.fromJson(Map<String, dynamic> json) => _$FeedBackInfoFromJson(json);
}

@freezed
class AudioMixs with _$AudioMixs {
  const factory AudioMixs({
    required String uuid,
    required String name,
    required Map<String, double> configs,
  }) = _AudioMixs;

  factory AudioMixs.fromJson(Map<String, dynamic> json) => _$AudioMixsFromJson(json);

  static AudioMixs empty() {
    return AudioMixs(uuid: newUuid(), name: "", configs: {});
  }
}

@freezed
class AudioConfig with _$AudioConfig {
  const factory AudioConfig({
    required String id,
    required String url,
    required String name,
    required double volumn,
    required String extra,
  }) = _AudioConfig;

  factory AudioConfig.fromJson(Map<String, dynamic> json) => _$AudioConfigFromJson(json);

  static AudioConfig fromUri(
    String url, {
    double volumn = 1.0,
    String extra = "",
    String? name,
  }) {
    // url: https://gitee.com/chen-hao91/publix_resource/raw/main/Nicaragua.mp3
    name = name ?? url.split("/").last.split(".").first;
    return AudioConfig(url: url, name: name, volumn: volumn, extra: extra, id: name);
  }

  static AudioConfig fromAssert(
    String fileName, {
    String? name,
    double volumn = 1.0,
    String extra = "",
  }) {
    var _name = name ?? fileName.split(".").first;
    // url: https://gitee.com/chen-hao91/publix_resource/raw/main/Nicaragua.mp3
    return AudioConfig(url: fileName, name: _name, volumn: volumn, extra: extra, id: fileName);
  }
}

@freezed
class ShortCutWrapper with _$ShortCutWrapper {
  const factory ShortCutWrapper({
    required String id,
    required List<int> keyIds,
  }) = _ShortCutWrapper;

  factory ShortCutWrapper.fromJson(Map<String, dynamic> json) => _$ShortCutWrapperFromJson(json);

  static ShortCutWrapper fromSet(String id, LogicalKeySet set) {
    return ShortCutWrapper(id: id, keyIds: set.keys.mapToList((i) => i.keyId));
  }
}

extension ShortCutWrapperExt on ShortCutWrapper {
  LogicalKeySet get keySet {
    var keys = this.keyIds.mapToSet((keyId) => LogicalKeyboardKey(keyId));
    return LogicalKeySet.fromSet(keys);
  }
}

extension AudioConfigExt on AudioConfig {
  List<String> get meta {
    if (extra.isEmptyOrNull || extra.isBlank) {
      return [];
    }
    Map<String, dynamic> map = json.decode(extra);
    return ((map["meta"] ?? []) as List<dynamic>).mapToList((e) => e.toString());
  }

  String get fileName {
    if (needDownload) {
      return name + "." + url.split(".").last;
    } else {
      return url;
    }
  }

  String? get localDownloadPath {
    if (needDownload) {
      return DownloadUtils.getPath(fileName: this.fileName, directory: DownloadConst.Audio);
    }
    return null;
  }

  bool get needDownload {
    return this.url.startsWith("http");
  }
}

@freezed
class PomodoroUnit with _$PomodoroUnit {
  const factory PomodoroUnit({
    required String uuid,
    required int notifyType,
    required int timeBlockType,
    required int minus,
    required Map<String, dynamic> extra,
  }) = _PomodoroUnit;

  factory PomodoroUnit.fromJson(Map<String, dynamic> json) => _$PomodoroUnitFromJson(json);

  static PomodoroUnit buildFocus({
    String? uuid,
    FocusEndAction? notifyType,
    required int minus,
  }) {
    return _PomodoroUnit(
        uuid: uuid ?? newUuid(),
        notifyType: (notifyType ?? FocusEndAction.defaultV).code,
        timeBlockType: TimeBlockType.FOCUS.code,
        minus: minus,
        extra: {});
  }

  static PomodoroUnit buildRest({
    String? uuid,
    FocusEndAction? notifyType,
    required int minus,
  }) {
    return _PomodoroUnit(
        uuid: uuid ?? newUuid(),
        notifyType: (notifyType ?? FocusEndAction.defaultV).code,
        timeBlockType: TimeBlockType.REST.code,
        minus: minus,
        extra: {});
  }
}

@freezed
class PomodoroPattern with _$PomodoroPattern {
  const factory PomodoroPattern({
    required String uuid,
    required List<PomodoroUnit> units,
    required String desc,
    required Map<String, dynamic> extra,
  }) = _PomodoroPattern;

  factory PomodoroPattern.fromJson(Map<String, dynamic> json) => _$PomodoroPatternFromJson(json);
}

extension PomodoroUnitExt on PomodoroUnit {
  bool get isFocus => this.timeBlockType == TimeBlockType.FOCUS.code;

  bool get isRest => this.timeBlockType == TimeBlockType.REST.code;

  TimeBlock mustFocus([int? minus]) {
    return buildTb(minus).whenFocus()!;
  }

  TimeBlock mustRest([int? minus]) {
    return buildTb(minus).whenRest()!;
  }

  TimeBlock buildTb([int? minus]) {
    if (this.isRest) {
      return TimeBlock.emptyCountDownRest(
        minutes: minus ?? this.minus,
      );
    } else {
      fnassert(() => this.isFocus);
      return TimeBlock.emptyFocus(
        minutes: minus ?? this.minus,
      );
    }
  }
}

enum SettingType {
  num('num'),
  bool('bool'),
  double("double"),
  shortcut('shortcut'),
  custom('custom'),
  unknow('unknow');

  final String key;

  const SettingType(this.key);

  static SettingType from(String key) {
    return SettingType.values.firstWhere((type) => type.key == key, orElse: () => SettingType.unknow);
  }
}

@freezed
class SettingItem with _$SettingItem {
  const factory SettingItem({
    required String key,
    required String title,
    String? description,
    String? groupTitle,
    required String type,
    List<String>? tags,
  }) = _SettingItem;

  static SettingItem fromSettingHolder<T>(
    SettingHolder<T> holder, {
    required String title,
    String? description,
    String? groupTitle,
    SettingType? type,
    List<String>? tags,
  }) {
    if (type == null) {
      type = SettingType.custom;
      if (holder.value is int) {
        type = SettingType.num;
      } else if (holder.value is bool) {
        type = SettingType.bool;
      } else if (holder.value is double) {
        type = SettingType.double;
      } else if (holder.value is String) {
        type = SettingType.custom; // Assuming custom type for String as there's no specific type for String in SettingType enum
      }
    }
    return SettingItem(
      key: holder.key,
      title: title,
      description: description,
      groupTitle: groupTitle,
      type: type.key,
      tags: tags,
    );
  }

  factory SettingItem.fromJson(Map<String, dynamic> json) => _$SettingItemFromJson(json);
}

extension SettingItemExt on SettingItem {
  bool match(String searchKey) {
    // title desc, tags groupTitle,
    // andy fzfMath
    return title.fzfMath(searchKey) ||
        (description?.fzfMath(searchKey) ?? false) ||
        (tags?.any((tag) => tag.fzfMath(searchKey)) ?? false) ||
        (groupTitle?.fzfMath(searchKey) ?? false);
  }
}
