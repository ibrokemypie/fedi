// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(json['username'], json['nickname'], json['id'], json['host'],
      json['avatarUrl'], json['url'])
    ..acct = json['acct'] as String;
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'username': instance.username,
      'nickname': instance.nickname,
      'id': instance.id,
      'host': instance.host,
      'avatarUrl': instance.avatarUrl,
      'url': instance.url,
      'acct': instance.acct
    };
