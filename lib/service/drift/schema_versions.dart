import 'package:drift/internal/versioned_schema.dart' as i0;
import 'package:drift/drift.dart' as i1;
import 'package:drift/drift.dart'; // ignore_for_file: type=lint,unused_import

// GENERATED BY drift_dev, DO NOT MODIFY.
final class Schema2 extends i0.VersionedSchema {
  Schema2({required super.database}) : super(version: 2);
  @override
  late final List<i1.DatabaseSchemaEntity> entities = [
    timeBlockTb,
    tagTb,
  ];
  late final Shape0 timeBlockTb = Shape0(
      source: i0.VersionedTable(
        entityName: 'time_block_tb',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY("key")',
        ],
        columns: [
          _column_0,
          _column_1,
          _column_2,
          _column_3,
          _column_4,
          _column_5,
          _column_6,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape1 tagTb = Shape1(
      source: i0.VersionedTable(
        entityName: 'tag_tb',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY("key")',
        ],
        columns: [
          _column_0,
          _column_7,
          _column_3,
          _column_8,
          _column_6,
        ],
        attachedDatabase: database,
      ),
      alias: null);
}

class Shape0 extends i0.VersionedTable {
  Shape0({required super.source, required super.alias}) : super.aliased();
  i1.GeneratedColumn<String> get key =>
      columnsByName['key']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get body =>
      columnsByName['body']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<int> get type =>
      columnsByName['type']! as i1.GeneratedColumn<int>;
  i1.GeneratedColumn<int> get status =>
      columnsByName['status']! as i1.GeneratedColumn<int>;
  i1.GeneratedColumn<DateTime> get startTime =>
      columnsByName['start_time']! as i1.GeneratedColumn<DateTime>;
  i1.GeneratedColumn<DateTime> get endTime =>
      columnsByName['end_time']! as i1.GeneratedColumn<DateTime>;
  i1.GeneratedColumn<DateTime> get modifyTime =>
      columnsByName['modify_time']! as i1.GeneratedColumn<DateTime>;
}

i1.GeneratedColumn<String> _column_0(String aliasedName) =>
    i1.GeneratedColumn<String>('key', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_1(String aliasedName) =>
    i1.GeneratedColumn<String>('body', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<int> _column_2(String aliasedName) =>
    i1.GeneratedColumn<int>('type', aliasedName, false,
        type: i1.DriftSqlType.int);
i1.GeneratedColumn<int> _column_3(String aliasedName) =>
    i1.GeneratedColumn<int>('status', aliasedName, false,
        type: i1.DriftSqlType.int);
i1.GeneratedColumn<DateTime> _column_4(String aliasedName) =>
    i1.GeneratedColumn<DateTime>('start_time', aliasedName, true,
        type: i1.DriftSqlType.dateTime);
i1.GeneratedColumn<DateTime> _column_5(String aliasedName) =>
    i1.GeneratedColumn<DateTime>('end_time', aliasedName, true,
        type: i1.DriftSqlType.dateTime);
i1.GeneratedColumn<DateTime> _column_6(String aliasedName) =>
    i1.GeneratedColumn<DateTime>('modify_time', aliasedName, true,
        type: i1.DriftSqlType.dateTime);

class Shape1 extends i0.VersionedTable {
  Shape1({required super.source, required super.alias}) : super.aliased();
  i1.GeneratedColumn<String> get key =>
      columnsByName['key']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get value =>
      columnsByName['value']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<int> get status =>
      columnsByName['status']! as i1.GeneratedColumn<int>;
  i1.GeneratedColumn<int> get colorValue =>
      columnsByName['color_value']! as i1.GeneratedColumn<int>;
  i1.GeneratedColumn<DateTime> get modifyTime =>
      columnsByName['modify_time']! as i1.GeneratedColumn<DateTime>;
}

i1.GeneratedColumn<String> _column_7(String aliasedName) =>
    i1.GeneratedColumn<String>('value', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<int> _column_8(String aliasedName) =>
    i1.GeneratedColumn<int>('color_value', aliasedName, true,
        type: i1.DriftSqlType.int);

final class Schema3 extends i0.VersionedSchema {
  Schema3({required super.database}) : super(version: 3);
  @override
  late final List<i1.DatabaseSchemaEntity> entities = [
    timeBlockTb,
    tagTb,
    settingTb,
  ];
  late final Shape0 timeBlockTb = Shape0(
      source: i0.VersionedTable(
        entityName: 'time_block_tb',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY("key")',
        ],
        columns: [
          _column_0,
          _column_1,
          _column_2,
          _column_3,
          _column_4,
          _column_5,
          _column_6,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape1 tagTb = Shape1(
      source: i0.VersionedTable(
        entityName: 'tag_tb',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY("key")',
        ],
        columns: [
          _column_0,
          _column_7,
          _column_3,
          _column_8,
          _column_6,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape2 settingTb = Shape2(
      source: i0.VersionedTable(
        entityName: 'setting_tb',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY("key")',
        ],
        columns: [
          _column_0,
          _column_7,
          _column_3,
          _column_6,
        ],
        attachedDatabase: database,
      ),
      alias: null);
}

class Shape2 extends i0.VersionedTable {
  Shape2({required super.source, required super.alias}) : super.aliased();
  i1.GeneratedColumn<String> get key =>
      columnsByName['key']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get value =>
      columnsByName['value']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<int> get status =>
      columnsByName['status']! as i1.GeneratedColumn<int>;
  i1.GeneratedColumn<DateTime> get modifyTime =>
      columnsByName['modify_time']! as i1.GeneratedColumn<DateTime>;
}

i0.MigrationStepWithVersion migrationSteps({
  required Future<void> Function(i1.Migrator m, Schema2 schema) from1To2,
  required Future<void> Function(i1.Migrator m, Schema3 schema) from2To3,
}) {
  return (currentVersion, database) async {
    switch (currentVersion) {
      case 1:
        final schema = Schema2(database: database);
        final migrator = i1.Migrator(database, schema);
        await from1To2(migrator, schema);
        return 2;
      case 2:
        final schema = Schema3(database: database);
        final migrator = i1.Migrator(database, schema);
        await from2To3(migrator, schema);
        return 3;
      default:
        throw ArgumentError.value('Unknown migration from $currentVersion');
    }
  };
}

i1.OnUpgrade stepByStep({
  required Future<void> Function(i1.Migrator m, Schema2 schema) from1To2,
  required Future<void> Function(i1.Migrator m, Schema3 schema) from2To3,
}) =>
    i0.VersionedSchema.stepByStepHelper(
        step: migrationSteps(
      from1To2: from1To2,
      from2To3: from2To3,
    ));
