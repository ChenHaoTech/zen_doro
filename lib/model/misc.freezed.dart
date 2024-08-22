// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'misc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FeedBackInfo _$FeedBackInfoFromJson(Map<String, dynamic> json) {
  return _FeedBackInfo.fromJson(json);
}

/// @nodoc
mixin _$FeedBackInfo {
  String get label => throw _privateConstructorUsedError;

  String get value => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FeedBackInfoCopyWith<FeedBackInfo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedBackInfoCopyWith<$Res> {
  factory $FeedBackInfoCopyWith(FeedBackInfo value, $Res Function(FeedBackInfo) then) = _$FeedBackInfoCopyWithImpl<$Res, FeedBackInfo>;

  @useResult
  $Res call({String label, String value});
}

/// @nodoc
class _$FeedBackInfoCopyWithImpl<$Res, $Val extends FeedBackInfo> implements $FeedBackInfoCopyWith<$Res> {
  _$FeedBackInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;

  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedBackInfoImplCopyWith<$Res> implements $FeedBackInfoCopyWith<$Res> {
  factory _$$FeedBackInfoImplCopyWith(_$FeedBackInfoImpl value, $Res Function(_$FeedBackInfoImpl) then) = __$$FeedBackInfoImplCopyWithImpl<$Res>;

  @override
  @useResult
  $Res call({String label, String value});
}

/// @nodoc
class __$$FeedBackInfoImplCopyWithImpl<$Res> extends _$FeedBackInfoCopyWithImpl<$Res, _$FeedBackInfoImpl>
    implements _$$FeedBackInfoImplCopyWith<$Res> {
  __$$FeedBackInfoImplCopyWithImpl(_$FeedBackInfoImpl _value, $Res Function(_$FeedBackInfoImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
  }) {
    return _then(_$FeedBackInfoImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedBackInfoImpl implements _FeedBackInfo {
  const _$FeedBackInfoImpl({required this.label, required this.value});

  factory _$FeedBackInfoImpl.fromJson(Map<String, dynamic> json) => _$$FeedBackInfoImplFromJson(json);

  @override
  final String label;
  @override
  final String value;

  @override
  String toString() {
    return 'FeedBackInfo(label: $label, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedBackInfoImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, label, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedBackInfoImplCopyWith<_$FeedBackInfoImpl> get copyWith => __$$FeedBackInfoImplCopyWithImpl<_$FeedBackInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedBackInfoImplToJson(
      this,
    );
  }
}

abstract class _FeedBackInfo implements FeedBackInfo {
  const factory _FeedBackInfo({required final String label, required final String value}) = _$FeedBackInfoImpl;

  factory _FeedBackInfo.fromJson(Map<String, dynamic> json) = _$FeedBackInfoImpl.fromJson;

  @override
  String get label;

  @override
  String get value;

  @override
  @JsonKey(ignore: true)
  _$$FeedBackInfoImplCopyWith<_$FeedBackInfoImpl> get copyWith => throw _privateConstructorUsedError;
}

AudioMixs _$AudioMixsFromJson(Map<String, dynamic> json) {
  return _AudioMixs.fromJson(json);
}

/// @nodoc
mixin _$AudioMixs {
  String get uuid => throw _privateConstructorUsedError;

  String get name => throw _privateConstructorUsedError;

  Map<String, double> get configs => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AudioMixsCopyWith<AudioMixs> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioMixsCopyWith<$Res> {
  factory $AudioMixsCopyWith(AudioMixs value, $Res Function(AudioMixs) then) = _$AudioMixsCopyWithImpl<$Res, AudioMixs>;

  @useResult
  $Res call({String uuid, String name, Map<String, double> configs});
}

/// @nodoc
class _$AudioMixsCopyWithImpl<$Res, $Val extends AudioMixs> implements $AudioMixsCopyWith<$Res> {
  _$AudioMixsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;

  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? name = null,
    Object? configs = null,
  }) {
    return _then(_value.copyWith(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      configs: null == configs
          ? _value.configs
          : configs // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AudioMixsImplCopyWith<$Res> implements $AudioMixsCopyWith<$Res> {
  factory _$$AudioMixsImplCopyWith(_$AudioMixsImpl value, $Res Function(_$AudioMixsImpl) then) = __$$AudioMixsImplCopyWithImpl<$Res>;

  @override
  @useResult
  $Res call({String uuid, String name, Map<String, double> configs});
}

/// @nodoc
class __$$AudioMixsImplCopyWithImpl<$Res> extends _$AudioMixsCopyWithImpl<$Res, _$AudioMixsImpl> implements _$$AudioMixsImplCopyWith<$Res> {
  __$$AudioMixsImplCopyWithImpl(_$AudioMixsImpl _value, $Res Function(_$AudioMixsImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? name = null,
    Object? configs = null,
  }) {
    return _then(_$AudioMixsImpl(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      configs: null == configs
          ? _value._configs
          : configs // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AudioMixsImpl implements _AudioMixs {
  const _$AudioMixsImpl({required this.uuid, required this.name, required final Map<String, double> configs}) : _configs = configs;

  factory _$AudioMixsImpl.fromJson(Map<String, dynamic> json) => _$$AudioMixsImplFromJson(json);

  @override
  final String uuid;
  @override
  final String name;
  final Map<String, double> _configs;

  @override
  Map<String, double> get configs {
    if (_configs is EqualUnmodifiableMapView) return _configs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_configs);
  }

  @override
  String toString() {
    return 'AudioMixs(uuid: $uuid, name: $name, configs: $configs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioMixsImpl &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._configs, _configs));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, uuid, name, const DeepCollectionEquality().hash(_configs));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioMixsImplCopyWith<_$AudioMixsImpl> get copyWith => __$$AudioMixsImplCopyWithImpl<_$AudioMixsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AudioMixsImplToJson(
      this,
    );
  }
}

abstract class _AudioMixs implements AudioMixs {
  const factory _AudioMixs({required final String uuid, required final String name, required final Map<String, double> configs}) = _$AudioMixsImpl;

  factory _AudioMixs.fromJson(Map<String, dynamic> json) = _$AudioMixsImpl.fromJson;

  @override
  String get uuid;

  @override
  String get name;

  @override
  Map<String, double> get configs;

  @override
  @JsonKey(ignore: true)
  _$$AudioMixsImplCopyWith<_$AudioMixsImpl> get copyWith => throw _privateConstructorUsedError;
}

AudioConfig _$AudioConfigFromJson(Map<String, dynamic> json) {
  return _AudioConfig.fromJson(json);
}

/// @nodoc
mixin _$AudioConfig {
  String get id => throw _privateConstructorUsedError;

  String get url => throw _privateConstructorUsedError;

  String get name => throw _privateConstructorUsedError;

  double get volumn => throw _privateConstructorUsedError;

  String get extra => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AudioConfigCopyWith<AudioConfig> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioConfigCopyWith<$Res> {
  factory $AudioConfigCopyWith(AudioConfig value, $Res Function(AudioConfig) then) = _$AudioConfigCopyWithImpl<$Res, AudioConfig>;

  @useResult
  $Res call({String id, String url, String name, double volumn, String extra});
}

/// @nodoc
class _$AudioConfigCopyWithImpl<$Res, $Val extends AudioConfig> implements $AudioConfigCopyWith<$Res> {
  _$AudioConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;

  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? name = null,
    Object? volumn = null,
    Object? extra = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      volumn: null == volumn
          ? _value.volumn
          : volumn // ignore: cast_nullable_to_non_nullable
              as double,
      extra: null == extra
          ? _value.extra
          : extra // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AudioConfigImplCopyWith<$Res> implements $AudioConfigCopyWith<$Res> {
  factory _$$AudioConfigImplCopyWith(_$AudioConfigImpl value, $Res Function(_$AudioConfigImpl) then) = __$$AudioConfigImplCopyWithImpl<$Res>;

  @override
  @useResult
  $Res call({String id, String url, String name, double volumn, String extra});
}

/// @nodoc
class __$$AudioConfigImplCopyWithImpl<$Res> extends _$AudioConfigCopyWithImpl<$Res, _$AudioConfigImpl> implements _$$AudioConfigImplCopyWith<$Res> {
  __$$AudioConfigImplCopyWithImpl(_$AudioConfigImpl _value, $Res Function(_$AudioConfigImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? name = null,
    Object? volumn = null,
    Object? extra = null,
  }) {
    return _then(_$AudioConfigImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      volumn: null == volumn
          ? _value.volumn
          : volumn // ignore: cast_nullable_to_non_nullable
              as double,
      extra: null == extra
          ? _value.extra
          : extra // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AudioConfigImpl implements _AudioConfig {
  const _$AudioConfigImpl({required this.id, required this.url, required this.name, required this.volumn, required this.extra});

  factory _$AudioConfigImpl.fromJson(Map<String, dynamic> json) => _$$AudioConfigImplFromJson(json);

  @override
  final String id;
  @override
  final String url;
  @override
  final String name;
  @override
  final double volumn;
  @override
  final String extra;

  @override
  String toString() {
    return 'AudioConfig(id: $id, url: $url, name: $name, volumn: $volumn, extra: $extra)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.volumn, volumn) || other.volumn == volumn) &&
            (identical(other.extra, extra) || other.extra == extra));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, url, name, volumn, extra);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioConfigImplCopyWith<_$AudioConfigImpl> get copyWith => __$$AudioConfigImplCopyWithImpl<_$AudioConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AudioConfigImplToJson(
      this,
    );
  }
}

abstract class _AudioConfig implements AudioConfig {
  const factory _AudioConfig(
      {required final String id,
      required final String url,
      required final String name,
      required final double volumn,
      required final String extra}) = _$AudioConfigImpl;

  factory _AudioConfig.fromJson(Map<String, dynamic> json) = _$AudioConfigImpl.fromJson;

  @override
  String get id;

  @override
  String get url;

  @override
  String get name;

  @override
  double get volumn;

  @override
  String get extra;

  @override
  @JsonKey(ignore: true)
  _$$AudioConfigImplCopyWith<_$AudioConfigImpl> get copyWith => throw _privateConstructorUsedError;
}

ShortCutWrapper _$ShortCutWrapperFromJson(Map<String, dynamic> json) {
  return _ShortCutWrapper.fromJson(json);
}

/// @nodoc
mixin _$ShortCutWrapper {
  String get id => throw _privateConstructorUsedError;

  List<int> get keyIds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ShortCutWrapperCopyWith<ShortCutWrapper> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShortCutWrapperCopyWith<$Res> {
  factory $ShortCutWrapperCopyWith(ShortCutWrapper value, $Res Function(ShortCutWrapper) then) = _$ShortCutWrapperCopyWithImpl<$Res, ShortCutWrapper>;

  @useResult
  $Res call({String id, List<int> keyIds});
}

/// @nodoc
class _$ShortCutWrapperCopyWithImpl<$Res, $Val extends ShortCutWrapper> implements $ShortCutWrapperCopyWith<$Res> {
  _$ShortCutWrapperCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;

  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? keyIds = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      keyIds: null == keyIds
          ? _value.keyIds
          : keyIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShortCutWrapperImplCopyWith<$Res> implements $ShortCutWrapperCopyWith<$Res> {
  factory _$$ShortCutWrapperImplCopyWith(_$ShortCutWrapperImpl value, $Res Function(_$ShortCutWrapperImpl) then) =
      __$$ShortCutWrapperImplCopyWithImpl<$Res>;

  @override
  @useResult
  $Res call({String id, List<int> keyIds});
}

/// @nodoc
class __$$ShortCutWrapperImplCopyWithImpl<$Res> extends _$ShortCutWrapperCopyWithImpl<$Res, _$ShortCutWrapperImpl>
    implements _$$ShortCutWrapperImplCopyWith<$Res> {
  __$$ShortCutWrapperImplCopyWithImpl(_$ShortCutWrapperImpl _value, $Res Function(_$ShortCutWrapperImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? keyIds = null,
  }) {
    return _then(_$ShortCutWrapperImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      keyIds: null == keyIds
          ? _value._keyIds
          : keyIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShortCutWrapperImpl implements _ShortCutWrapper {
  const _$ShortCutWrapperImpl({required this.id, required final List<int> keyIds}) : _keyIds = keyIds;

  factory _$ShortCutWrapperImpl.fromJson(Map<String, dynamic> json) => _$$ShortCutWrapperImplFromJson(json);

  @override
  final String id;
  final List<int> _keyIds;

  @override
  List<int> get keyIds {
    if (_keyIds is EqualUnmodifiableListView) return _keyIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keyIds);
  }

  @override
  String toString() {
    return 'ShortCutWrapper(id: $id, keyIds: $keyIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShortCutWrapperImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._keyIds, _keyIds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, const DeepCollectionEquality().hash(_keyIds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShortCutWrapperImplCopyWith<_$ShortCutWrapperImpl> get copyWith => __$$ShortCutWrapperImplCopyWithImpl<_$ShortCutWrapperImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShortCutWrapperImplToJson(
      this,
    );
  }
}

abstract class _ShortCutWrapper implements ShortCutWrapper {
  const factory _ShortCutWrapper({required final String id, required final List<int> keyIds}) = _$ShortCutWrapperImpl;

  factory _ShortCutWrapper.fromJson(Map<String, dynamic> json) = _$ShortCutWrapperImpl.fromJson;

  @override
  String get id;

  @override
  List<int> get keyIds;

  @override
  @JsonKey(ignore: true)
  _$$ShortCutWrapperImplCopyWith<_$ShortCutWrapperImpl> get copyWith => throw _privateConstructorUsedError;
}

PomodoroUnit _$PomodoroUnitFromJson(Map<String, dynamic> json) {
  return _PomodoroUnit.fromJson(json);
}

/// @nodoc
mixin _$PomodoroUnit {
  String get uuid => throw _privateConstructorUsedError;

  int get notifyType => throw _privateConstructorUsedError;

  int get timeBlockType => throw _privateConstructorUsedError;

  int get minus => throw _privateConstructorUsedError;

  Map<String, dynamic> get extra => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PomodoroUnitCopyWith<PomodoroUnit> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PomodoroUnitCopyWith<$Res> {
  factory $PomodoroUnitCopyWith(PomodoroUnit value, $Res Function(PomodoroUnit) then) = _$PomodoroUnitCopyWithImpl<$Res, PomodoroUnit>;

  @useResult
  $Res call({String uuid, int notifyType, int timeBlockType, int minus, Map<String, dynamic> extra});
}

/// @nodoc
class _$PomodoroUnitCopyWithImpl<$Res, $Val extends PomodoroUnit> implements $PomodoroUnitCopyWith<$Res> {
  _$PomodoroUnitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;

  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? notifyType = null,
    Object? timeBlockType = null,
    Object? minus = null,
    Object? extra = null,
  }) {
    return _then(_value.copyWith(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      notifyType: null == notifyType
          ? _value.notifyType
          : notifyType // ignore: cast_nullable_to_non_nullable
              as int,
      timeBlockType: null == timeBlockType
          ? _value.timeBlockType
          : timeBlockType // ignore: cast_nullable_to_non_nullable
              as int,
      minus: null == minus
          ? _value.minus
          : minus // ignore: cast_nullable_to_non_nullable
              as int,
      extra: null == extra
          ? _value.extra
          : extra // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PomodoroUnitImplCopyWith<$Res> implements $PomodoroUnitCopyWith<$Res> {
  factory _$$PomodoroUnitImplCopyWith(_$PomodoroUnitImpl value, $Res Function(_$PomodoroUnitImpl) then) = __$$PomodoroUnitImplCopyWithImpl<$Res>;

  @override
  @useResult
  $Res call({String uuid, int notifyType, int timeBlockType, int minus, Map<String, dynamic> extra});
}

/// @nodoc
class __$$PomodoroUnitImplCopyWithImpl<$Res> extends _$PomodoroUnitCopyWithImpl<$Res, _$PomodoroUnitImpl>
    implements _$$PomodoroUnitImplCopyWith<$Res> {
  __$$PomodoroUnitImplCopyWithImpl(_$PomodoroUnitImpl _value, $Res Function(_$PomodoroUnitImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? notifyType = null,
    Object? timeBlockType = null,
    Object? minus = null,
    Object? extra = null,
  }) {
    return _then(_$PomodoroUnitImpl(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      notifyType: null == notifyType
          ? _value.notifyType
          : notifyType // ignore: cast_nullable_to_non_nullable
              as int,
      timeBlockType: null == timeBlockType
          ? _value.timeBlockType
          : timeBlockType // ignore: cast_nullable_to_non_nullable
              as int,
      minus: null == minus
          ? _value.minus
          : minus // ignore: cast_nullable_to_non_nullable
              as int,
      extra: null == extra
          ? _value._extra
          : extra // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PomodoroUnitImpl implements _PomodoroUnit {
  const _$PomodoroUnitImpl(
      {required this.uuid, required this.notifyType, required this.timeBlockType, required this.minus, required final Map<String, dynamic> extra})
      : _extra = extra;

  factory _$PomodoroUnitImpl.fromJson(Map<String, dynamic> json) => _$$PomodoroUnitImplFromJson(json);

  @override
  final String uuid;
  @override
  final int notifyType;
  @override
  final int timeBlockType;
  @override
  final int minus;
  final Map<String, dynamic> _extra;

  @override
  Map<String, dynamic> get extra {
    if (_extra is EqualUnmodifiableMapView) return _extra;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_extra);
  }

  @override
  String toString() {
    return 'PomodoroUnit(uuid: $uuid, notifyType: $notifyType, timeBlockType: $timeBlockType, minus: $minus, extra: $extra)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PomodoroUnitImpl &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.notifyType, notifyType) || other.notifyType == notifyType) &&
            (identical(other.timeBlockType, timeBlockType) || other.timeBlockType == timeBlockType) &&
            (identical(other.minus, minus) || other.minus == minus) &&
            const DeepCollectionEquality().equals(other._extra, _extra));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, uuid, notifyType, timeBlockType, minus, const DeepCollectionEquality().hash(_extra));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PomodoroUnitImplCopyWith<_$PomodoroUnitImpl> get copyWith => __$$PomodoroUnitImplCopyWithImpl<_$PomodoroUnitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PomodoroUnitImplToJson(
      this,
    );
  }
}

abstract class _PomodoroUnit implements PomodoroUnit {
  const factory _PomodoroUnit(
      {required final String uuid,
      required final int notifyType,
      required final int timeBlockType,
      required final int minus,
      required final Map<String, dynamic> extra}) = _$PomodoroUnitImpl;

  factory _PomodoroUnit.fromJson(Map<String, dynamic> json) = _$PomodoroUnitImpl.fromJson;

  @override
  String get uuid;

  @override
  int get notifyType;

  @override
  int get timeBlockType;

  @override
  int get minus;

  @override
  Map<String, dynamic> get extra;

  @override
  @JsonKey(ignore: true)
  _$$PomodoroUnitImplCopyWith<_$PomodoroUnitImpl> get copyWith => throw _privateConstructorUsedError;
}

PomodoroPattern _$PomodoroPatternFromJson(Map<String, dynamic> json) {
  return _PomodoroPattern.fromJson(json);
}

/// @nodoc
mixin _$PomodoroPattern {
  String get uuid => throw _privateConstructorUsedError;

  List<PomodoroUnit> get units => throw _privateConstructorUsedError;

  String get desc => throw _privateConstructorUsedError;

  Map<String, dynamic> get extra => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PomodoroPatternCopyWith<PomodoroPattern> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PomodoroPatternCopyWith<$Res> {
  factory $PomodoroPatternCopyWith(PomodoroPattern value, $Res Function(PomodoroPattern) then) = _$PomodoroPatternCopyWithImpl<$Res, PomodoroPattern>;

  @useResult
  $Res call({String uuid, List<PomodoroUnit> units, String desc, Map<String, dynamic> extra});
}

/// @nodoc
class _$PomodoroPatternCopyWithImpl<$Res, $Val extends PomodoroPattern> implements $PomodoroPatternCopyWith<$Res> {
  _$PomodoroPatternCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;

  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? units = null,
    Object? desc = null,
    Object? extra = null,
  }) {
    return _then(_value.copyWith(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      units: null == units
          ? _value.units
          : units // ignore: cast_nullable_to_non_nullable
              as List<PomodoroUnit>,
      desc: null == desc
          ? _value.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String,
      extra: null == extra
          ? _value.extra
          : extra // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PomodoroPatternImplCopyWith<$Res> implements $PomodoroPatternCopyWith<$Res> {
  factory _$$PomodoroPatternImplCopyWith(_$PomodoroPatternImpl value, $Res Function(_$PomodoroPatternImpl) then) =
      __$$PomodoroPatternImplCopyWithImpl<$Res>;

  @override
  @useResult
  $Res call({String uuid, List<PomodoroUnit> units, String desc, Map<String, dynamic> extra});
}

/// @nodoc
class __$$PomodoroPatternImplCopyWithImpl<$Res> extends _$PomodoroPatternCopyWithImpl<$Res, _$PomodoroPatternImpl>
    implements _$$PomodoroPatternImplCopyWith<$Res> {
  __$$PomodoroPatternImplCopyWithImpl(_$PomodoroPatternImpl _value, $Res Function(_$PomodoroPatternImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? units = null,
    Object? desc = null,
    Object? extra = null,
  }) {
    return _then(_$PomodoroPatternImpl(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      units: null == units
          ? _value._units
          : units // ignore: cast_nullable_to_non_nullable
              as List<PomodoroUnit>,
      desc: null == desc
          ? _value.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String,
      extra: null == extra
          ? _value._extra
          : extra // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PomodoroPatternImpl implements _PomodoroPattern {
  const _$PomodoroPatternImpl(
      {required this.uuid, required final List<PomodoroUnit> units, required this.desc, required final Map<String, dynamic> extra})
      : _units = units,
        _extra = extra;

  factory _$PomodoroPatternImpl.fromJson(Map<String, dynamic> json) => _$$PomodoroPatternImplFromJson(json);

  @override
  final String uuid;
  final List<PomodoroUnit> _units;

  @override
  List<PomodoroUnit> get units {
    if (_units is EqualUnmodifiableListView) return _units;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_units);
  }

  @override
  final String desc;
  final Map<String, dynamic> _extra;

  @override
  Map<String, dynamic> get extra {
    if (_extra is EqualUnmodifiableMapView) return _extra;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_extra);
  }

  @override
  String toString() {
    return 'PomodoroPattern(uuid: $uuid, units: $units, desc: $desc, extra: $extra)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PomodoroPatternImpl &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            const DeepCollectionEquality().equals(other._units, _units) &&
            (identical(other.desc, desc) || other.desc == desc) &&
            const DeepCollectionEquality().equals(other._extra, _extra));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, uuid, const DeepCollectionEquality().hash(_units), desc, const DeepCollectionEquality().hash(_extra));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PomodoroPatternImplCopyWith<_$PomodoroPatternImpl> get copyWith => __$$PomodoroPatternImplCopyWithImpl<_$PomodoroPatternImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PomodoroPatternImplToJson(
      this,
    );
  }
}

abstract class _PomodoroPattern implements PomodoroPattern {
  const factory _PomodoroPattern(
      {required final String uuid,
      required final List<PomodoroUnit> units,
      required final String desc,
      required final Map<String, dynamic> extra}) = _$PomodoroPatternImpl;

  factory _PomodoroPattern.fromJson(Map<String, dynamic> json) = _$PomodoroPatternImpl.fromJson;

  @override
  String get uuid;

  @override
  List<PomodoroUnit> get units;

  @override
  String get desc;

  @override
  Map<String, dynamic> get extra;

  @override
  @JsonKey(ignore: true)
  _$$PomodoroPatternImplCopyWith<_$PomodoroPatternImpl> get copyWith => throw _privateConstructorUsedError;
}

SettingItem _$SettingItemFromJson(Map<String, dynamic> json) {
  return _SettingItem.fromJson(json);
}

/// @nodoc
mixin _$SettingItem {
  String get key => throw _privateConstructorUsedError;

  String get title => throw _privateConstructorUsedError;

  String? get description => throw _privateConstructorUsedError;

  String? get groupTitle => throw _privateConstructorUsedError;

  String get type => throw _privateConstructorUsedError;

  List<String>? get tags => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SettingItemCopyWith<SettingItem> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingItemCopyWith<$Res> {
  factory $SettingItemCopyWith(SettingItem value, $Res Function(SettingItem) then) = _$SettingItemCopyWithImpl<$Res, SettingItem>;

  @useResult
  $Res call({String key, String title, String? description, String? groupTitle, String type, List<String>? tags});
}

/// @nodoc
class _$SettingItemCopyWithImpl<$Res, $Val extends SettingItem> implements $SettingItemCopyWith<$Res> {
  _$SettingItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;

  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? title = null,
    Object? description = freezed,
    Object? groupTitle = freezed,
    Object? type = null,
    Object? tags = freezed,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      groupTitle: freezed == groupTitle
          ? _value.groupTitle
          : groupTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettingItemImplCopyWith<$Res> implements $SettingItemCopyWith<$Res> {
  factory _$$SettingItemImplCopyWith(_$SettingItemImpl value, $Res Function(_$SettingItemImpl) then) = __$$SettingItemImplCopyWithImpl<$Res>;

  @override
  @useResult
  $Res call({String key, String title, String? description, String? groupTitle, String type, List<String>? tags});
}

/// @nodoc
class __$$SettingItemImplCopyWithImpl<$Res> extends _$SettingItemCopyWithImpl<$Res, _$SettingItemImpl> implements _$$SettingItemImplCopyWith<$Res> {
  __$$SettingItemImplCopyWithImpl(_$SettingItemImpl _value, $Res Function(_$SettingItemImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? title = null,
    Object? description = freezed,
    Object? groupTitle = freezed,
    Object? type = null,
    Object? tags = freezed,
  }) {
    return _then(_$SettingItemImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      groupTitle: freezed == groupTitle
          ? _value.groupTitle
          : groupTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SettingItemImpl implements _SettingItem {
  const _$SettingItemImpl({required this.key, required this.title, this.description, this.groupTitle, required this.type, final List<String>? tags})
      : _tags = tags;

  factory _$SettingItemImpl.fromJson(Map<String, dynamic> json) => _$$SettingItemImplFromJson(json);

  @override
  final String key;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? groupTitle;
  @override
  final String type;
  final List<String>? _tags;

  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'SettingItem(key: $key, title: $title, description: $description, groupTitle: $groupTitle, type: $type, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingItemImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) || other.description == description) &&
            (identical(other.groupTitle, groupTitle) || other.groupTitle == groupTitle) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, key, title, description, groupTitle, type, const DeepCollectionEquality().hash(_tags));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingItemImplCopyWith<_$SettingItemImpl> get copyWith => __$$SettingItemImplCopyWithImpl<_$SettingItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettingItemImplToJson(
      this,
    );
  }
}

abstract class _SettingItem implements SettingItem {
  const factory _SettingItem(
      {required final String key,
      required final String title,
      final String? description,
      final String? groupTitle,
      required final String type,
      final List<String>? tags}) = _$SettingItemImpl;

  factory _SettingItem.fromJson(Map<String, dynamic> json) = _$SettingItemImpl.fromJson;

  @override
  String get key;

  @override
  String get title;

  @override
  String? get description;

  @override
  String? get groupTitle;

  @override
  String get type;

  @override
  List<String>? get tags;

  @override
  @JsonKey(ignore: true)
  _$$SettingItemImplCopyWith<_$SettingItemImpl> get copyWith => throw _privateConstructorUsedError;
}
