// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_block.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ActionLog _$ActionLogFromJson(Map<String, dynamic> json) {
  return _ActionLog.fromJson(json);
}

/// @nodoc
mixin _$ActionLog {
  int get type => throw _privateConstructorUsedError;
  DateTime get time => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ActionLogCopyWith<ActionLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActionLogCopyWith<$Res> {
  factory $ActionLogCopyWith(ActionLog value, $Res Function(ActionLog) then) =
      _$ActionLogCopyWithImpl<$Res, ActionLog>;
  @useResult
  $Res call({int type, DateTime time});
}

/// @nodoc
class _$ActionLogCopyWithImpl<$Res, $Val extends ActionLog>
    implements $ActionLogCopyWith<$Res> {
  _$ActionLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? time = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActionLogImplCopyWith<$Res>
    implements $ActionLogCopyWith<$Res> {
  factory _$$ActionLogImplCopyWith(
          _$ActionLogImpl value, $Res Function(_$ActionLogImpl) then) =
      __$$ActionLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int type, DateTime time});
}

/// @nodoc
class __$$ActionLogImplCopyWithImpl<$Res>
    extends _$ActionLogCopyWithImpl<$Res, _$ActionLogImpl>
    implements _$$ActionLogImplCopyWith<$Res> {
  __$$ActionLogImplCopyWithImpl(
      _$ActionLogImpl _value, $Res Function(_$ActionLogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? time = null,
  }) {
    return _then(_$ActionLogImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActionLogImpl implements _ActionLog {
  const _$ActionLogImpl({required this.type, required this.time});

  factory _$ActionLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActionLogImplFromJson(json);

  @override
  final int type;
  @override
  final DateTime time;

  @override
  String toString() {
    return 'ActionLog(type: $type, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActionLogImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.time, time) || other.time == time));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, type, time);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ActionLogImplCopyWith<_$ActionLogImpl> get copyWith =>
      __$$ActionLogImplCopyWithImpl<_$ActionLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActionLogImplToJson(
      this,
    );
  }
}

abstract class _ActionLog implements ActionLog {
  const factory _ActionLog(
      {required final int type,
      required final DateTime time}) = _$ActionLogImpl;

  factory _ActionLog.fromJson(Map<String, dynamic> json) =
      _$ActionLogImpl.fromJson;

  @override
  int get type;
  @override
  DateTime get time;
  @override
  @JsonKey(ignore: true)
  _$$ActionLogImplCopyWith<_$ActionLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FocusBlock _$FocusBlockFromJson(Map<String, dynamic> json) {
  return _FocusBlock.fromJson(json);
}

/// @nodoc
mixin _$FocusBlock {
  int get durationSeconds =>
      throw _privateConstructorUsedError; /*如果杀进程进来, 那么就有用，因为是每秒都维护的*/
  int get progressSeconds => throw _privateConstructorUsedError;
  List<String> get logs => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get context => throw _privateConstructorUsedError;
  String? get feedback => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FocusBlockCopyWith<FocusBlock> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FocusBlockCopyWith<$Res> {
  factory $FocusBlockCopyWith(
          FocusBlock value, $Res Function(FocusBlock) then) =
      _$FocusBlockCopyWithImpl<$Res, FocusBlock>;
  @useResult
  $Res call(
      {int durationSeconds,
      int progressSeconds,
      List<String> logs,
      List<String> tags,
      String? title,
      String? context,
      String? feedback});
}

/// @nodoc
class _$FocusBlockCopyWithImpl<$Res, $Val extends FocusBlock>
    implements $FocusBlockCopyWith<$Res> {
  _$FocusBlockCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? durationSeconds = null,
    Object? progressSeconds = null,
    Object? logs = null,
    Object? tags = null,
    Object? title = freezed,
    Object? context = freezed,
    Object? feedback = freezed,
  }) {
    return _then(_value.copyWith(
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      progressSeconds: null == progressSeconds
          ? _value.progressSeconds
          : progressSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      logs: null == logs
          ? _value.logs
          : logs // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      context: freezed == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as String?,
      feedback: freezed == feedback
          ? _value.feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FocusBlockImplCopyWith<$Res>
    implements $FocusBlockCopyWith<$Res> {
  factory _$$FocusBlockImplCopyWith(
          _$FocusBlockImpl value, $Res Function(_$FocusBlockImpl) then) =
      __$$FocusBlockImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int durationSeconds,
      int progressSeconds,
      List<String> logs,
      List<String> tags,
      String? title,
      String? context,
      String? feedback});
}

/// @nodoc
class __$$FocusBlockImplCopyWithImpl<$Res>
    extends _$FocusBlockCopyWithImpl<$Res, _$FocusBlockImpl>
    implements _$$FocusBlockImplCopyWith<$Res> {
  __$$FocusBlockImplCopyWithImpl(
      _$FocusBlockImpl _value, $Res Function(_$FocusBlockImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? durationSeconds = null,
    Object? progressSeconds = null,
    Object? logs = null,
    Object? tags = null,
    Object? title = freezed,
    Object? context = freezed,
    Object? feedback = freezed,
  }) {
    return _then(_$FocusBlockImpl(
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      progressSeconds: null == progressSeconds
          ? _value.progressSeconds
          : progressSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      logs: null == logs
          ? _value._logs
          : logs // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      context: freezed == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as String?,
      feedback: freezed == feedback
          ? _value.feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FocusBlockImpl implements _FocusBlock {
  const _$FocusBlockImpl(
      {required this.durationSeconds,
      required this.progressSeconds,
      final List<String> logs = const [],
      final List<String> tags = const [],
      this.title,
      this.context,
      this.feedback})
      : _logs = logs,
        _tags = tags;

  factory _$FocusBlockImpl.fromJson(Map<String, dynamic> json) =>
      _$$FocusBlockImplFromJson(json);

  @override
  final int durationSeconds;
/*如果杀进程进来, 那么就有用，因为是每秒都维护的*/
  @override
  final int progressSeconds;
  final List<String> _logs;
  @override
  @JsonKey()
  List<String> get logs {
    if (_logs is EqualUnmodifiableListView) return _logs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_logs);
  }

  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String? title;
  @override
  final String? context;
  @override
  final String? feedback;

  @override
  String toString() {
    return 'FocusBlock(durationSeconds: $durationSeconds, progressSeconds: $progressSeconds, logs: $logs, tags: $tags, title: $title, context: $context, feedback: $feedback)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FocusBlockImpl &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.progressSeconds, progressSeconds) ||
                other.progressSeconds == progressSeconds) &&
            const DeepCollectionEquality().equals(other._logs, _logs) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.context, context) || other.context == context) &&
            (identical(other.feedback, feedback) ||
                other.feedback == feedback));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      durationSeconds,
      progressSeconds,
      const DeepCollectionEquality().hash(_logs),
      const DeepCollectionEquality().hash(_tags),
      title,
      context,
      feedback);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FocusBlockImplCopyWith<_$FocusBlockImpl> get copyWith =>
      __$$FocusBlockImplCopyWithImpl<_$FocusBlockImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FocusBlockImplToJson(
      this,
    );
  }
}

abstract class _FocusBlock implements FocusBlock {
  const factory _FocusBlock(
      {required final int durationSeconds,
      required final int progressSeconds,
      final List<String> logs,
      final List<String> tags,
      final String? title,
      final String? context,
      final String? feedback}) = _$FocusBlockImpl;

  factory _FocusBlock.fromJson(Map<String, dynamic> json) =
      _$FocusBlockImpl.fromJson;

  @override
  int get durationSeconds;
  @override /*如果杀进程进来, 那么就有用，因为是每秒都维护的*/
  int get progressSeconds;
  @override
  List<String> get logs;
  @override
  List<String> get tags;
  @override
  String? get title;
  @override
  String? get context;
  @override
  String? get feedback;
  @override
  @JsonKey(ignore: true)
  _$$FocusBlockImplCopyWith<_$FocusBlockImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RestBlock _$RestBlockFromJson(Map<String, dynamic> json) {
  return _Rest.fromJson(json);
}

/// @nodoc
mixin _$RestBlock {
  int get type => throw _privateConstructorUsedError;
  int get progressSeconds => throw _privateConstructorUsedError;
  int get durationSeconds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RestBlockCopyWith<RestBlock> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestBlockCopyWith<$Res> {
  factory $RestBlockCopyWith(RestBlock value, $Res Function(RestBlock) then) =
      _$RestBlockCopyWithImpl<$Res, RestBlock>;
  @useResult
  $Res call({int type, int progressSeconds, int durationSeconds});
}

/// @nodoc
class _$RestBlockCopyWithImpl<$Res, $Val extends RestBlock>
    implements $RestBlockCopyWith<$Res> {
  _$RestBlockCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? progressSeconds = null,
    Object? durationSeconds = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      progressSeconds: null == progressSeconds
          ? _value.progressSeconds
          : progressSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RestImplCopyWith<$Res> implements $RestBlockCopyWith<$Res> {
  factory _$$RestImplCopyWith(
          _$RestImpl value, $Res Function(_$RestImpl) then) =
      __$$RestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int type, int progressSeconds, int durationSeconds});
}

/// @nodoc
class __$$RestImplCopyWithImpl<$Res>
    extends _$RestBlockCopyWithImpl<$Res, _$RestImpl>
    implements _$$RestImplCopyWith<$Res> {
  __$$RestImplCopyWithImpl(_$RestImpl _value, $Res Function(_$RestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? progressSeconds = null,
    Object? durationSeconds = null,
  }) {
    return _then(_$RestImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      progressSeconds: null == progressSeconds
          ? _value.progressSeconds
          : progressSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RestImpl implements _Rest {
  const _$RestImpl(
      {required this.type,
      required this.progressSeconds,
      required this.durationSeconds});

  factory _$RestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RestImplFromJson(json);

  @override
  final int type;
  @override
  final int progressSeconds;
  @override
  final int durationSeconds;

  @override
  String toString() {
    return 'RestBlock(type: $type, progressSeconds: $progressSeconds, durationSeconds: $durationSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.progressSeconds, progressSeconds) ||
                other.progressSeconds == progressSeconds) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, progressSeconds, durationSeconds);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RestImplCopyWith<_$RestImpl> get copyWith =>
      __$$RestImplCopyWithImpl<_$RestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RestImplToJson(
      this,
    );
  }
}

abstract class _Rest implements RestBlock {
  const factory _Rest(
      {required final int type,
      required final int progressSeconds,
      required final int durationSeconds}) = _$RestImpl;

  factory _Rest.fromJson(Map<String, dynamic> json) = _$RestImpl.fromJson;

  @override
  int get type;
  @override
  int get progressSeconds;
  @override
  int get durationSeconds;
  @override
  @JsonKey(ignore: true)
  _$$RestImplCopyWith<_$RestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimeBlock _$TimeBlockFromJson(Map<String, dynamic> json) {
  return _TimeBlock.fromJson(json);
}

/// @nodoc
mixin _$TimeBlock {
  String get uuid => throw _privateConstructorUsedError;
  @JsonKey(name: "body", readValue: _deceodeBody)
  String get body => throw _privateConstructorUsedError; //TimeBlockType
  int get type => throw _privateConstructorUsedError;
  DateTime? get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  DateTime? get modifyTime => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TimeBlockCopyWith<TimeBlock> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeBlockCopyWith<$Res> {
  factory $TimeBlockCopyWith(TimeBlock value, $Res Function(TimeBlock) then) =
      _$TimeBlockCopyWithImpl<$Res, TimeBlock>;
  @useResult
  $Res call(
      {String uuid,
      @JsonKey(name: "body", readValue: _deceodeBody) String body,
      int type,
      DateTime? startTime,
      DateTime? endTime,
      DateTime? modifyTime});
}

/// @nodoc
class _$TimeBlockCopyWithImpl<$Res, $Val extends TimeBlock>
    implements $TimeBlockCopyWith<$Res> {
  _$TimeBlockCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? body = null,
    Object? type = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? modifyTime = freezed,
  }) {
    return _then(_value.copyWith(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      modifyTime: freezed == modifyTime
          ? _value.modifyTime
          : modifyTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeBlockImplCopyWith<$Res>
    implements $TimeBlockCopyWith<$Res> {
  factory _$$TimeBlockImplCopyWith(
          _$TimeBlockImpl value, $Res Function(_$TimeBlockImpl) then) =
      __$$TimeBlockImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uuid,
      @JsonKey(name: "body", readValue: _deceodeBody) String body,
      int type,
      DateTime? startTime,
      DateTime? endTime,
      DateTime? modifyTime});
}

/// @nodoc
class __$$TimeBlockImplCopyWithImpl<$Res>
    extends _$TimeBlockCopyWithImpl<$Res, _$TimeBlockImpl>
    implements _$$TimeBlockImplCopyWith<$Res> {
  __$$TimeBlockImplCopyWithImpl(
      _$TimeBlockImpl _value, $Res Function(_$TimeBlockImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? body = null,
    Object? type = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? modifyTime = freezed,
  }) {
    return _then(_$TimeBlockImpl(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      modifyTime: freezed == modifyTime
          ? _value.modifyTime
          : modifyTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeBlockImpl implements _TimeBlock {
  const _$TimeBlockImpl(
      {required this.uuid,
      @JsonKey(name: "body", readValue: _deceodeBody) required this.body,
      required this.type,
      this.startTime,
      this.endTime,
      this.modifyTime});

  factory _$TimeBlockImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeBlockImplFromJson(json);

  @override
  final String uuid;
  @override
  @JsonKey(name: "body", readValue: _deceodeBody)
  final String body;
//TimeBlockType
  @override
  final int type;
  @override
  final DateTime? startTime;
  @override
  final DateTime? endTime;
  @override
  final DateTime? modifyTime;

  @override
  String toString() {
    return 'TimeBlock(uuid: $uuid, body: $body, type: $type, startTime: $startTime, endTime: $endTime, modifyTime: $modifyTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeBlockImpl &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.modifyTime, modifyTime) ||
                other.modifyTime == modifyTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, uuid, body, type, startTime, endTime, modifyTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeBlockImplCopyWith<_$TimeBlockImpl> get copyWith =>
      __$$TimeBlockImplCopyWithImpl<_$TimeBlockImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeBlockImplToJson(
      this,
    );
  }
}

abstract class _TimeBlock implements TimeBlock {
  const factory _TimeBlock(
      {required final String uuid,
      @JsonKey(name: "body", readValue: _deceodeBody)
      required final String body,
      required final int type,
      final DateTime? startTime,
      final DateTime? endTime,
      final DateTime? modifyTime}) = _$TimeBlockImpl;

  factory _TimeBlock.fromJson(Map<String, dynamic> json) =
      _$TimeBlockImpl.fromJson;

  @override
  String get uuid;
  @override
  @JsonKey(name: "body", readValue: _deceodeBody)
  String get body;
  @override //TimeBlockType
  int get type;
  @override
  DateTime? get startTime;
  @override
  DateTime? get endTime;
  @override
  DateTime? get modifyTime;
  @override
  @JsonKey(ignore: true)
  _$$TimeBlockImplCopyWith<_$TimeBlockImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Tag _$TagFromJson(Map<String, dynamic> json) {
  return _Tag.fromJson(json);
}

/// @nodoc
mixin _$Tag {
  String get id => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  int? get colorValue => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TagCopyWith<Tag> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TagCopyWith<$Res> {
  factory $TagCopyWith(Tag value, $Res Function(Tag) then) =
      _$TagCopyWithImpl<$Res, Tag>;
  @useResult
  $Res call({String id, String value, int? colorValue});
}

/// @nodoc
class _$TagCopyWithImpl<$Res, $Val extends Tag> implements $TagCopyWith<$Res> {
  _$TagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? value = null,
    Object? colorValue = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      colorValue: freezed == colorValue
          ? _value.colorValue
          : colorValue // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TagImplCopyWith<$Res> implements $TagCopyWith<$Res> {
  factory _$$TagImplCopyWith(_$TagImpl value, $Res Function(_$TagImpl) then) =
      __$$TagImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String value, int? colorValue});
}

/// @nodoc
class __$$TagImplCopyWithImpl<$Res> extends _$TagCopyWithImpl<$Res, _$TagImpl>
    implements _$$TagImplCopyWith<$Res> {
  __$$TagImplCopyWithImpl(_$TagImpl _value, $Res Function(_$TagImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? value = null,
    Object? colorValue = freezed,
  }) {
    return _then(_$TagImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      colorValue: freezed == colorValue
          ? _value.colorValue
          : colorValue // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TagImpl implements _Tag {
  const _$TagImpl({required this.id, required this.value, this.colorValue});

  factory _$TagImpl.fromJson(Map<String, dynamic> json) =>
      _$$TagImplFromJson(json);

  @override
  final String id;
  @override
  final String value;
  @override
  final int? colorValue;

  @override
  String toString() {
    return 'Tag(id: $id, value: $value, colorValue: $colorValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TagImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, value, colorValue);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TagImplCopyWith<_$TagImpl> get copyWith =>
      __$$TagImplCopyWithImpl<_$TagImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TagImplToJson(
      this,
    );
  }
}

abstract class _Tag implements Tag {
  const factory _Tag(
      {required final String id,
      required final String value,
      final int? colorValue}) = _$TagImpl;

  factory _Tag.fromJson(Map<String, dynamic> json) = _$TagImpl.fromJson;

  @override
  String get id;
  @override
  String get value;
  @override
  int? get colorValue;
  @override
  @JsonKey(ignore: true)
  _$$TagImplCopyWith<_$TagImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
