// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Instance _$InstanceFromJson(Map<String, dynamic> json) {
  return Instance(
      json['uri'] as String,
      json['protocol'] as String,
      json['host'] as String,
      json['title'] as String,
      json['description'] as String,
      json['version'] as String,
      json['type'] as String)
    ..maxChars = json['maxChars'] as int
    ..emojiList = (json['emojiList'] as List)
        ?.map((e) => e == null ? null : Emoji.fromJson(e as Map))
        ?.toList();
}

Map<String, dynamic> _$InstanceToJson(Instance instance) => <String, dynamic>{
      'type': instance.type,
      'uri': instance.uri,
      'title': instance.title,
      'description': instance.description,
      'version': instance.version,
      'protocol': instance.protocol,
      'host': instance.host,
      'maxChars': instance.maxChars,
      'emojiList': instance.emojiList
    };
