// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TimeBlock_tbTable extends TimeBlock_tb
    with TableInfo<$TimeBlock_tbTable, TimeBlock_tbData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimeBlock_tbTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _modifyTimeMeta =
      const VerificationMeta('modifyTime');
  @override
  late final GeneratedColumn<DateTime> modifyTime = GeneratedColumn<DateTime>(
      'modify_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [key, body, type, status, startTime, endTime, modifyTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'time_block_tb';
  @override
  VerificationContext validateIntegrity(Insertable<TimeBlock_tbData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('modify_time')) {
      context.handle(
          _modifyTimeMeta,
          modifyTime.isAcceptableOrUnknown(
              data['modify_time']!, _modifyTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  TimeBlock_tbData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeBlock_tbData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time']),
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      modifyTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}modify_time']),
    );
  }

  @override
  $TimeBlock_tbTable createAlias(String alias) {
    return $TimeBlock_tbTable(attachedDatabase, alias);
  }
}

class TimeBlock_tbData extends DataClass
    implements Insertable<TimeBlock_tbData> {
  final String key;
  final String body;
  final int type;
/**
   * SyncStatus
   */
  final int status;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? modifyTime;
  const TimeBlock_tbData(
      {required this.key,
      required this.body,
      required this.type,
      required this.status,
      this.startTime,
      this.endTime,
      this.modifyTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['body'] = Variable<String>(body);
    map['type'] = Variable<int>(type);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<DateTime>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    if (!nullToAbsent || modifyTime != null) {
      map['modify_time'] = Variable<DateTime>(modifyTime);
    }
    return map;
  }

  TimeBlock_tbCompanion toCompanion(bool nullToAbsent) {
    return TimeBlock_tbCompanion(
      key: Value(key),
      body: Value(body),
      type: Value(type),
      status: Value(status),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      modifyTime: modifyTime == null && nullToAbsent
          ? const Value.absent()
          : Value(modifyTime),
    );
  }

  factory TimeBlock_tbData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeBlock_tbData(
      key: serializer.fromJson<String>(json['key']),
      body: serializer.fromJson<String>(json['body']),
      type: serializer.fromJson<int>(json['type']),
      status: serializer.fromJson<int>(json['status']),
      startTime: serializer.fromJson<DateTime?>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      modifyTime: serializer.fromJson<DateTime?>(json['modifyTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'body': serializer.toJson<String>(body),
      'type': serializer.toJson<int>(type),
      'status': serializer.toJson<int>(status),
      'startTime': serializer.toJson<DateTime?>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'modifyTime': serializer.toJson<DateTime?>(modifyTime),
    };
  }

  TimeBlock_tbData copyWith(
          {String? key,
          String? body,
          int? type,
          int? status,
          Value<DateTime?> startTime = const Value.absent(),
          Value<DateTime?> endTime = const Value.absent(),
          Value<DateTime?> modifyTime = const Value.absent()}) =>
      TimeBlock_tbData(
        key: key ?? this.key,
        body: body ?? this.body,
        type: type ?? this.type,
        status: status ?? this.status,
        startTime: startTime.present ? startTime.value : this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        modifyTime: modifyTime.present ? modifyTime.value : this.modifyTime,
      );
  @override
  String toString() {
    return (StringBuffer('TimeBlock_tbData(')
          ..write('key: $key, ')
          ..write('body: $body, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('modifyTime: $modifyTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(key, body, type, status, startTime, endTime, modifyTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeBlock_tbData &&
          other.key == this.key &&
          other.body == this.body &&
          other.type == this.type &&
          other.status == this.status &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.modifyTime == this.modifyTime);
}

class TimeBlock_tbCompanion extends UpdateCompanion<TimeBlock_tbData> {
  final Value<String> key;
  final Value<String> body;
  final Value<int> type;
  final Value<int> status;
  final Value<DateTime?> startTime;
  final Value<DateTime?> endTime;
  final Value<DateTime?> modifyTime;
  final Value<int> rowid;
  const TimeBlock_tbCompanion({
    this.key = const Value.absent(),
    this.body = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.modifyTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimeBlock_tbCompanion.insert({
    required String key,
    required String body,
    required int type,
    required int status,
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.modifyTime = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        body = Value(body),
        type = Value(type),
        status = Value(status);
  static Insertable<TimeBlock_tbData> custom({
    Expression<String>? key,
    Expression<String>? body,
    Expression<int>? type,
    Expression<int>? status,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<DateTime>? modifyTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (body != null) 'body': body,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (modifyTime != null) 'modify_time': modifyTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimeBlock_tbCompanion copyWith(
      {Value<String>? key,
      Value<String>? body,
      Value<int>? type,
      Value<int>? status,
      Value<DateTime?>? startTime,
      Value<DateTime?>? endTime,
      Value<DateTime?>? modifyTime,
      Value<int>? rowid}) {
    return TimeBlock_tbCompanion(
      key: key ?? this.key,
      body: body ?? this.body,
      type: type ?? this.type,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      modifyTime: modifyTime ?? this.modifyTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (modifyTime.present) {
      map['modify_time'] = Variable<DateTime>(modifyTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimeBlock_tbCompanion(')
          ..write('key: $key, ')
          ..write('body: $body, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('modifyTime: $modifyTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $Tag_tbTable extends Tag_tb with TableInfo<$Tag_tbTable, Tag_tbData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $Tag_tbTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _modifyTimeMeta =
      const VerificationMeta('modifyTime');
  @override
  late final GeneratedColumn<DateTime> modifyTime = GeneratedColumn<DateTime>(
      'modify_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [key, value, status, colorValue, modifyTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tag_tb';
  @override
  VerificationContext validateIntegrity(Insertable<Tag_tbData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    }
    if (data.containsKey('modify_time')) {
      context.handle(
          _modifyTimeMeta,
          modifyTime.isAcceptableOrUnknown(
              data['modify_time']!, _modifyTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Tag_tbData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag_tbData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value']),
      modifyTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}modify_time']),
    );
  }

  @override
  $Tag_tbTable createAlias(String alias) {
    return $Tag_tbTable(attachedDatabase, alias);
  }
}

class Tag_tbData extends DataClass implements Insertable<Tag_tbData> {
  final String key;
  final String value;
  final int status;
  final int? colorValue;
  final DateTime? modifyTime;
  const Tag_tbData(
      {required this.key,
      required this.value,
      required this.status,
      this.colorValue,
      this.modifyTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || colorValue != null) {
      map['color_value'] = Variable<int>(colorValue);
    }
    if (!nullToAbsent || modifyTime != null) {
      map['modify_time'] = Variable<DateTime>(modifyTime);
    }
    return map;
  }

  Tag_tbCompanion toCompanion(bool nullToAbsent) {
    return Tag_tbCompanion(
      key: Value(key),
      value: Value(value),
      status: Value(status),
      colorValue: colorValue == null && nullToAbsent
          ? const Value.absent()
          : Value(colorValue),
      modifyTime: modifyTime == null && nullToAbsent
          ? const Value.absent()
          : Value(modifyTime),
    );
  }

  factory Tag_tbData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag_tbData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      status: serializer.fromJson<int>(json['status']),
      colorValue: serializer.fromJson<int?>(json['colorValue']),
      modifyTime: serializer.fromJson<DateTime?>(json['modifyTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'status': serializer.toJson<int>(status),
      'colorValue': serializer.toJson<int?>(colorValue),
      'modifyTime': serializer.toJson<DateTime?>(modifyTime),
    };
  }

  Tag_tbData copyWith(
          {String? key,
          String? value,
          int? status,
          Value<int?> colorValue = const Value.absent(),
          Value<DateTime?> modifyTime = const Value.absent()}) =>
      Tag_tbData(
        key: key ?? this.key,
        value: value ?? this.value,
        status: status ?? this.status,
        colorValue: colorValue.present ? colorValue.value : this.colorValue,
        modifyTime: modifyTime.present ? modifyTime.value : this.modifyTime,
      );
  @override
  String toString() {
    return (StringBuffer('Tag_tbData(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('status: $status, ')
          ..write('colorValue: $colorValue, ')
          ..write('modifyTime: $modifyTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, status, colorValue, modifyTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag_tbData &&
          other.key == this.key &&
          other.value == this.value &&
          other.status == this.status &&
          other.colorValue == this.colorValue &&
          other.modifyTime == this.modifyTime);
}

class Tag_tbCompanion extends UpdateCompanion<Tag_tbData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> status;
  final Value<int?> colorValue;
  final Value<DateTime?> modifyTime;
  final Value<int> rowid;
  const Tag_tbCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.status = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.modifyTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  Tag_tbCompanion.insert({
    required String key,
    required String value,
    required int status,
    this.colorValue = const Value.absent(),
    this.modifyTime = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value),
        status = Value(status);
  static Insertable<Tag_tbData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? status,
    Expression<int>? colorValue,
    Expression<DateTime>? modifyTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (status != null) 'status': status,
      if (colorValue != null) 'color_value': colorValue,
      if (modifyTime != null) 'modify_time': modifyTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  Tag_tbCompanion copyWith(
      {Value<String>? key,
      Value<String>? value,
      Value<int>? status,
      Value<int?>? colorValue,
      Value<DateTime?>? modifyTime,
      Value<int>? rowid}) {
    return Tag_tbCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      status: status ?? this.status,
      colorValue: colorValue ?? this.colorValue,
      modifyTime: modifyTime ?? this.modifyTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (modifyTime.present) {
      map['modify_time'] = Variable<DateTime>(modifyTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('Tag_tbCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('status: $status, ')
          ..write('colorValue: $colorValue, ')
          ..write('modifyTime: $modifyTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $Setting_tbTable extends Setting_tb
    with TableInfo<$Setting_tbTable, Setting_tbData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $Setting_tbTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _modifyTimeMeta =
      const VerificationMeta('modifyTime');
  @override
  late final GeneratedColumn<DateTime> modifyTime = GeneratedColumn<DateTime>(
      'modify_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [key, value, status, modifyTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting_tb';
  @override
  VerificationContext validateIntegrity(Insertable<Setting_tbData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('modify_time')) {
      context.handle(
          _modifyTimeMeta,
          modifyTime.isAcceptableOrUnknown(
              data['modify_time']!, _modifyTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting_tbData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting_tbData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      modifyTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}modify_time']),
    );
  }

  @override
  $Setting_tbTable createAlias(String alias) {
    return $Setting_tbTable(attachedDatabase, alias);
  }
}

class Setting_tbData extends DataClass implements Insertable<Setting_tbData> {
  final String key;
  final String value;
  final int status;
  final DateTime? modifyTime;
  const Setting_tbData(
      {required this.key,
      required this.value,
      required this.status,
      this.modifyTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || modifyTime != null) {
      map['modify_time'] = Variable<DateTime>(modifyTime);
    }
    return map;
  }

  Setting_tbCompanion toCompanion(bool nullToAbsent) {
    return Setting_tbCompanion(
      key: Value(key),
      value: Value(value),
      status: Value(status),
      modifyTime: modifyTime == null && nullToAbsent
          ? const Value.absent()
          : Value(modifyTime),
    );
  }

  factory Setting_tbData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting_tbData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      status: serializer.fromJson<int>(json['status']),
      modifyTime: serializer.fromJson<DateTime?>(json['modifyTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'status': serializer.toJson<int>(status),
      'modifyTime': serializer.toJson<DateTime?>(modifyTime),
    };
  }

  Setting_tbData copyWith(
          {String? key,
          String? value,
          int? status,
          Value<DateTime?> modifyTime = const Value.absent()}) =>
      Setting_tbData(
        key: key ?? this.key,
        value: value ?? this.value,
        status: status ?? this.status,
        modifyTime: modifyTime.present ? modifyTime.value : this.modifyTime,
      );
  @override
  String toString() {
    return (StringBuffer('Setting_tbData(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('status: $status, ')
          ..write('modifyTime: $modifyTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, status, modifyTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting_tbData &&
          other.key == this.key &&
          other.value == this.value &&
          other.status == this.status &&
          other.modifyTime == this.modifyTime);
}

class Setting_tbCompanion extends UpdateCompanion<Setting_tbData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> status;
  final Value<DateTime?> modifyTime;
  final Value<int> rowid;
  const Setting_tbCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.status = const Value.absent(),
    this.modifyTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  Setting_tbCompanion.insert({
    required String key,
    required String value,
    required int status,
    this.modifyTime = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value),
        status = Value(status);
  static Insertable<Setting_tbData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? status,
    Expression<DateTime>? modifyTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (status != null) 'status': status,
      if (modifyTime != null) 'modify_time': modifyTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  Setting_tbCompanion copyWith(
      {Value<String>? key,
      Value<String>? value,
      Value<int>? status,
      Value<DateTime?>? modifyTime,
      Value<int>? rowid}) {
    return Setting_tbCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      status: status ?? this.status,
      modifyTime: modifyTime ?? this.modifyTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (modifyTime.present) {
      map['modify_time'] = Variable<DateTime>(modifyTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('Setting_tbCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('status: $status, ')
          ..write('modifyTime: $modifyTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $TimeBlock_tbTable timeBlockTb = $TimeBlock_tbTable(this);
  late final $Tag_tbTable tagTb = $Tag_tbTable(this);
  late final $Setting_tbTable settingTb = $Setting_tbTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [timeBlockTb, tagTb, settingTb];
}
