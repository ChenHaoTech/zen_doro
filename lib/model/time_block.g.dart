// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActionLogImpl _$$ActionLogImplFromJson(Map<String, dynamic> json) =>
    _$ActionLogImpl(
      type: (json['type'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
    );

Map<String, dynamic> _$$ActionLogImplToJson(_$ActionLogImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'time': instance.time.toIso8601String(),
    };

_$FocusBlockImpl _$$FocusBlockImplFromJson(Map<String, dynamic> json) =>
    _$FocusBlockImpl(
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      progressSeconds: (json['progressSeconds'] as num).toInt(),
      logs:
          (json['logs'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      title: json['title'] as String?,
      context: json['context'] as String?,
      feedback: json['feedback'] as String?,
    );

Map<String, dynamic> _$$FocusBlockImplToJson(_$FocusBlockImpl instance) =>
    <String, dynamic>{
      'durationSeconds': instance.durationSeconds,
      'progressSeconds': instance.progressSeconds,
      'logs': instance.logs,
      'tags': instance.tags,
      'title': instance.title,
      'context': instance.context,
      'feedback': instance.feedback,
    };

_$RestImpl _$$RestImplFromJson(Map<String, dynamic> json) => _$RestImpl(
      type: (json['type'] as num).toInt(),
      progressSeconds: (json['progressSeconds'] as num).toInt(),
      durationSeconds: (json['durationSeconds'] as num).toInt(),
    );

Map<String, dynamic> _$$RestImplToJson(_$RestImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'progressSeconds': instance.progressSeconds,
      'durationSeconds': instance.durationSeconds,
    };

_$TimeBlockImpl _$$TimeBlockImplFromJson(Map<String, dynamic> json) =>
    _$TimeBlockImpl(
      uuid: json['uuid'] as String,
      body: _deceodeBody(json, 'body') as String,
      type: (json['type'] as num).toInt(),
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      modifyTime: json['modifyTime'] == null
          ? null
          : DateTime.parse(json['modifyTime'] as String),
    );

Map<String, dynamic> _$$TimeBlockImplToJson(_$TimeBlockImpl instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'body': instance.body,
      'type': instance.type,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'modifyTime': instance.modifyTime?.toIso8601String(),
    };

_$TagImpl _$$TagImplFromJson(Map<String, dynamic> json) => _$TagImpl(
      id: json['id'] as String,
      value: json['value'] as String,
      colorValue: (json['colorValue'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$TagImplToJson(_$TagImpl instance) => <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
      'colorValue': instance.colorValue,
    };
