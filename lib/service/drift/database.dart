import 'package:drift/drift.dart';
import 'package:flutter_pasteboard/main.dart';
import 'package:flutter_pasteboard/misc/fn_notification.dart';
import 'package:flutter_pasteboard/misc/i18n/local_extension.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:get/get.dart' hide Value;
import 'package:hive/hive.dart';

import 'connection_unsupport.dart' if (dart.library.ffi) 'connection_native.dart' if (dart.library.html) 'connection_web.dart';
import 'schema_versions.dart'; // ignore_for_file: camel_case_types

part 'database.g.dart';

final int $version = 14;

enum SyncStatus {
  UN_SYNC(0),
  SYNC_ING(1),
  SYNC_ED(2),
  ;

  final int code;

  const SyncStatus(this.code);
}

class TimeBlock_tb extends Table {
  TextColumn get key => text()();

  TextColumn get body => text()();

  IntColumn get type => integer()();

  /**
   * SyncStatus
   */
  IntColumn get status => integer()();

  DateTimeColumn get startTime => dateTime().nullable()();

  DateTimeColumn get endTime => dateTime().nullable()();

  DateTimeColumn get modifyTime => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

class Tag_tb extends Table {
  TextColumn get key => text()();

  TextColumn get value => text()();

  IntColumn get status => integer()();

  IntColumn get colorValue => integer().nullable()();

  DateTimeColumn get modifyTime => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

class Setting_tb extends Table {
  TextColumn get key => text()();

  TextColumn get value => text()();

  IntColumn get status => integer()();

  DateTimeColumn get modifyTime => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [TimeBlock_tb, Tag_tb, Setting_tb])
class AppDatabase extends _$AppDatabase {
  static AppDatabase get get {
    return Get.find<AppDatabase>();
  }

  Future reUpload() async {
    var tbCnt = await timeBlockTb.update().write(TimeBlock_tbCompanion.custom(status: Constant(SyncStatus.UN_SYNC.code)));
    var tagCnt = await tagTb.update().write(Tag_tbCompanion.custom(status: Constant(SyncStatus.UN_SYNC.code)));
    this.log.dd(() => "mark dirty: tb: ${tbCnt},tag: ${tagCnt}");
  }

  Future reDownload() async {
    await appCache.put("_innerVersion", appCache.get("_innerVersion", defaultValue: 0) + 1);
    FnNotification.toast("mark success, please restart".i18n);
  }

  Future dispose() async {
    try {
      await this.close();
      Get.delete<AppDatabase>(force: true);
    } catch (e) {
      this.log.e("appdatabase close fail: ", e);
    }
  }

  static String _current_database_key = "current_database_key_${$version}";

  static Future setCurrentDataBaseKey(Box box, String value) async {
    await box.put(_current_database_key, value);
  }

  static AppDatabase register(String key) {
    return Get.put<AppDatabase>(AppDatabase(key: key), permanent: true);
  }

  static String $getCurrentDataBaseKey(Box box) {
    return box.get(_current_database_key, defaultValue: "");
  }

  late final String? key;

  AppDatabase({this.key, QueryExecutor? qe}) : super(qe ?? openConnection(key!));

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: stepByStep(
        from1To2: (m, schema) async {
          await m.addColumn(schema.timeBlockTb, schema.timeBlockTb.modifyTime);
        },
        from2To3: (Migrator m, Schema3 schema) async {
          await m.createTable(schema.settingTb);
        },
      ),
    );
  }

  @override
  int get schemaVersion => 3;
}