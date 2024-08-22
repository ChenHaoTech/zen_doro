import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/service/drift/database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_pasteboard/service/setting_service.dart';

extension TimeBlockDbExt on TimeBlock_tbData {
  TimeBlock toModel() {
    return TimeBlock(
      uuid: this.key,
      body: this.body,
      type: this.type,
      startTime: this.startTime,
      endTime: this.endTime,
      modifyTime: this.modifyTime,
    );
  }
}

extension TimeBlockExt on TimeBlock {
  TimeBlock_tbCompanion toTbCompanion() {
    var timeBlock = this;
    return TimeBlock_tbCompanion.insert(
      modifyTime: drift.Value(timeBlock.modifyTime ?? DateTime.now()),
      key: timeBlock.uuid,
      body: timeBlock.body,
      type: timeBlock.type,
      startTime: drift.Value(timeBlock.startTime),
      endTime: drift.Value(timeBlock.endTime),
      status: SyncStatus.UN_SYNC.code,
    );
  }
}

extension TagExt on Tag {
  Tag_tbCompanion toTbCompanion() {
    var tag = this;
    return Tag_tbCompanion.insert(
      key: tag.id,
      status: SyncStatus.UN_SYNC.code,
      modifyTime: drift.Value(DateTime.now()),
      colorValue: drift.Value(tag.colorValue),
      value: this.value,
    );
  }
}

extension Tag_tbDataExt on Tag_tbData {
  Tag toModel() {
    return Tag(
      value: this.value,
      colorValue: this.colorValue,
      id: this.key,
    );
  }
}

extension SettingHolderExt<T> on SettingHolder<T> {
  Setting_tbCompanion toTbCompanion(
    String Function(T)? serialize,
  ) {
    return Setting_tbCompanion.insert(
      key: this.key,
      status: SyncStatus.UN_SYNC.code,
      modifyTime: drift.Value(DateTime.now()),
      value: serialize?.call(this.justValue) ?? this.justValue.toJsonStr(),
    );
  }

  void accept(
    Setting_tbData tb,
    T Function(String)? deserialize,
  ) {
    var obj = deserialize?.call(tb.value) ?? tb.value;
    this.value = obj as T;
  }
}
