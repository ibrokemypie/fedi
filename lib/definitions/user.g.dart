// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
      username: json['username'],
      nickname: json['nickname'],
      id: json['id'],
      host: json['host'],
      avatarUrl: json['avatarUrl'],
      bannerUrl: json['bannerUrl'],
      url: json['url'],
      description: json['description'],
      fields: json['fields'],
      followersCount: json['followersCount'],
      followingCount: json['followingCount'],
      statusCount: json['statusCount'])
    ..acct = json['acct'] as String;
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'username': instance.username,
      'nickname': instance.nickname,
      'id': instance.id,
      'host': instance.host,
      'avatarUrl': instance.avatarUrl,
      'bannerUrl': instance.bannerUrl,
      'url': instance.url,
      'acct': instance.acct,
      'description': instance.description,
      'fields': instance.fields,
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
      'statusCount': instance.statusCount
    };
