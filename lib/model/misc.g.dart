// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeedBackInfoImpl _$$FeedBackInfoImplFromJson(Map<String, dynamic> json) =>
    _$FeedBackInfoImpl(
      label: json['label'] as String,
      value: json['value'] as String,
    );

Map<String, dynamic> _$$FeedBackInfoImplToJson(_$FeedBackInfoImpl instance) =>
    <String, dynamic>{
      'label': instance.label,
      'value': instance.value,
    };

_$AudioMixsImpl _$$AudioMixsImplFromJson(Map<String, dynamic> json) =>
    _$AudioMixsImpl(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      configs: (json['configs'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$$AudioMixsImplToJson(_$AudioMixsImpl instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'configs': instance.configs,
    };

_$AudioConfigImpl _$$AudioConfigImplFromJson(Map<String, dynamic> json) =>
    _$AudioConfigImpl(
      id: json['id'] as String,
      url: json['url'] as String,
      name: json['name'] as String,
      volumn: (json['volumn'] as num).toDouble(),
      extra: json['extra'] as String,
    );

Map<String, dynamic> _$$AudioConfigImplToJson(_$AudioConfigImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'name': instance.name,
      'volumn': instance.volumn,
      'extra': instance.extra,
    };

_$ShortCutWrapperImpl _$$ShortCutWrapperImplFromJson(
        Map<String, dynamic> json) =>
    _$ShortCutWrapperImpl(
      id: json['id'] as String,
      keyIds: (json['keyIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$$ShortCutWrapperImplToJson(
        _$ShortCutWrapperImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'keyIds': instance.keyIds,
    };

_$PomodoroUnitImpl _$$PomodoroUnitImplFromJson(Map<String, dynamic> json) =>
    _$PomodoroUnitImpl(
      uuid: json['uuid'] as String,
      notifyType: (json['notifyType'] as num).toInt(),
      timeBlockType: (json['timeBlockType'] as num).toInt(),
      minus: (json['minus'] as num).toInt(),
      extra: json['extra'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$PomodoroUnitImplToJson(_$PomodoroUnitImpl instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'notifyType': instance.notifyType,
      'timeBlockType': instance.timeBlockType,
      'minus': instance.minus,
      'extra': instance.extra,
    };

_$PomodoroPatternImpl _$$PomodoroPatternImplFromJson(
        Map<String, dynamic> json) =>
    _$PomodoroPatternImpl(
      uuid: json['uuid'] as String,
      units: (json['units'] as List<dynamic>)
          .map((e) => PomodoroUnit.fromJson(e as Map<String, dynamic>))
          .toList(),
      desc: json['desc'] as String,
      extra: json['extra'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$PomodoroPatternImplToJson(
        _$PomodoroPatternImpl instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'units': instance.units,
      'desc': instance.desc,
      'extra': instance.extra,
    };

_$SettingItemImpl _$$SettingItemImplFromJson(Map<String, dynamic> json) =>
    _$SettingItemImpl(
      key: json['key'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      groupTitle: json['groupTitle'] as String?,
      type: json['type'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$SettingItemImplToJson(_$SettingItemImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'title': instance.title,
      'description': instance.description,
      'groupTitle': instance.groupTitle,
      'type': instance.type,
      'tags': instance.tags,
    };
