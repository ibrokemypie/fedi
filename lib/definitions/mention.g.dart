// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mention.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mention _$MentionFromJson(Map<String, dynamic> json) {
  return Mention(
      json['id'], json['username'], json['host'], json['acct'], json['url']);
}

Map<String, dynamic> _$MentionToJson(Mention instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'host': instance.host,
      'acct': instance.acct,
      'url': instance.url
    };
