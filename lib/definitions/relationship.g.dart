// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Relationship _$RelationshipFromJson(Map<String, dynamic> json) {
  return Relationship(
      followedByMe: json['followedByMe'],
      followingMe: json['followingMe'],
      requestedFollow: json['requestedFollow'],
      blocked: json['blocked'],
      muted: json['muted']);
}

Map<String, dynamic> _$RelationshipToJson(Relationship instance) =>
    <String, dynamic>{
      'followedByMe': instance.followedByMe,
      'followingMe': instance.followingMe,
      'requestedFollow': instance.requestedFollow,
      'blocked': instance.blocked,
      'muted': instance.muted
    };
