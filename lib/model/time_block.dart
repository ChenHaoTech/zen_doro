import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:daily_extensions/daily_extensions.dart';
import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:duration/duration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pasteboard/misc/date_utils.dart';
import 'package:flutter_pasteboard/misc/debugUtils.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/misc/function.dart';
import 'package:flutter_pasteboard/misc/i18n/!!export.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:flutter_pasteboard/misc/tag_utils.dart';
import 'package:flutter_pasteboard/model/model_share.dart';
import 'package:flutter_pasteboard/service/setting_service.dart';
import 'package:flutter_pasteboard/service/tag_store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../service/time_block_store.dart';

export './model_share.dart';

part 'time_block.freezed.dart';
part 'time_block.g.dart';
part 'time_block_extension.dart';

@freezed
class ActionLog with _$ActionLog {
  const factory ActionLog({
    required int type,
    required DateTime time,
  }) = _ActionLog;

  factory ActionLog.fromJson(Map<String, dynamic> json) => _$ActionLogFromJson(json);
}

@freezed
class FocusBlock with _$FocusBlock {
  const factory FocusBlock({
    required int durationSeconds,
    /*如果杀进程进来, 那么就有用，因为是每秒都维护的*/
    required int progressSeconds,
    @Default([]) List<String> logs,
    @Default([]) List<String> tags,
    String? title,
    String? context,
    String? feedback,
  }) = _FocusBlock;

  factory FocusBlock.fromJson(Map<String, dynamic> json) => _$FocusBlockFromJson(json);
}

@freezed
class RestBlock with _$RestBlock {
  const factory RestBlock({
    required int type,
    required int progressSeconds,
    required int durationSeconds,
  }) = _Rest;

  factory RestBlock.fromJson(Map<String, dynamic> json) => _$RestBlockFromJson(json);
}

String _deceodeBody(Map<dynamic, dynamic> jsonMap, String key) {
  print("key:${key},jsonMap: ${jsonMap}");
  var json = (jsonMap[key] as String).toSafeJson();
  _adapterBodyJson(json);
  return json.toJsonStr();
}

Map<dynamic, dynamic> _adapterBodyJson(Map<dynamic, dynamic> jsonMap) {
  // 新建版本兼容
  jsonMap.putIfAbsent("progressSeconds", () => 0);
  var durationSeconds = max((jsonMap["progressSeconds"] ?? 0) as int, 0) + max((jsonMap["leftSeconds"] as int?) ?? 0, 0);
  jsonMap.putIfAbsent("durationSeconds", () => durationSeconds);
  return jsonMap;
}

@freezed
class TimeBlock with _$TimeBlock {
  const factory TimeBlock({
    required String uuid,
    @JsonKey(name: "body", readValue: _deceodeBody) required String body,
    //TimeBlockType
    required int type,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? modifyTime,
  }) = _TimeBlock;

  factory TimeBlock.fromJson(Map<String, dynamic> json) => _$TimeBlockFromJson(json);

  static TimeBlock emptyFocus({
    int? minutes,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    int duration =
        ((endTime?.difference(startTime!).inSeconds ?? (minutes?.fnmap((val) => val * 60))) ?? SettingService.instance.defaultFocusMinus.value * 60);
    var progress = 0;
    if (startTime != null) {
      var difDur = FnDateUtils.min(DateTime.now(), endTime ?? DateTime.now()).difference(startTime);
      progress = difDur.inSeconds;
      fnassert(() => progress <= duration, ["minutes 太小了", duration]);
    }
    return TimeBlock(
            startTime: startTime,
            endTime: endTime,
            uuid: newUuid(),
            body: FocusBlock(
              title: title,
              durationSeconds: duration,
              progressSeconds: progress,
            ).toJsonStr(),
            type: TimeBlockType.FOCUS.code)
        .assertTimeBlockRule();
  }

  static TimeBlock emptyCountDownRest({
    int? minutes,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    int duration =
        ((endTime?.difference(startTime!).inSeconds ?? (minutes?.fnmap((val) => val * 60))) ?? SettingService.instance.defaultFocusMinus.value * 60);
    var progress = 0;
    if (startTime != null) {
      var difDur = FnDateUtils.min(DateTime.now(), endTime ?? DateTime.now()).difference(startTime);
      progress = difDur.inSeconds;
      fnassert(() => progress <= duration, ["minutes 太小了", duration]);
    }
    return TimeBlock(
            startTime: startTime,
            endTime: endTime,
            uuid: newUuid(),
            body: RestBlock(
              type: RestType.COUNT_DOWN.code,
              progressSeconds: progress,
              durationSeconds: duration,
            ).toJsonStr(),
            type: TimeBlockType.REST.code)
        .assertTimeBlockRule();
  }
// static TimeBlock fromDb()
}

@freezed
class Tag with _$Tag {
  const factory Tag({
    required String id,
    required String value,
    int? colorValue,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  static Tag empty(String value) {
    return Tag(value: value, id: value);
  }
}

abstract class TimeBlockListUtils {
  static Map<DateTime, List<TimeBlock>> groupByDate(List<TimeBlock> timeBlocks) {
    return timeBlocks.where((element) => element.isFocus && element.startTime != null).groupListsBy((i) => i.startTime!.onlyYmd());
  }

  static Map<String, List<TimeBlock>> groupByTag(List<TimeBlock> timeBlocks) {
    Map<String, List<TimeBlock>> result = {};
    for (var tb in timeBlocks) {
      var promodo = tb.tryPromodo;
      if (promodo == null) continue;
      if (promodo.tags.isEmptyOrNull) {
        result.putIfAbsent("", () => []);
        result[""]!.add(tb);
      } else {
        for (var tag in promodo.tags) {
          result.putIfAbsent(tag, () => []);
          result[tag]!.add(tb);
        }
      }
    }
    return result;
  }

  static Map<String, List<TimeBlock>> groupByFeedback(List<TimeBlock> timeBlocks) {
    return timeBlocks.where((element) => element.isFocus && element.startTime != null).groupListsBy((i) => i.pomodoro.feedback ?? "");
  }

  static Map<String, List<TimeBlock>> groupByTask(List<TimeBlock> timeBlocks) {
    return timeBlocks.where((element) => element.isFocus && element.startTime != null).groupListsBy((i) => i.pomodoro.titleWithoutTag?.trim() ?? "");
  }
}
