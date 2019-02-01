// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) {
  return Item(
      json['id'],
      json['date'],
      json['author'],
      json['url'],
      json['contentWarning'],
      json['body'],
      json['visibility'],
      json['favourited'],
      json['favCount'],
      json['myReaction'],
      json['renoteCount'],
      json['replyCount'],
      json['attachments'],
      json['renote'],
      json['notificationType'],
      json['isRead'],
      json['notificationNote'],
      json['emoji'],
      json['mentions']);
}

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'author': instance.author,
      'url': instance.url,
      'contentWarning': instance.contentWarning,
      'body': instance.body,
      'visibility': instance.visibility,
      'favourited': instance.favourited,
      'favCount': instance.favCount,
      'myReaction': instance.myReaction,
      'renoteCount': instance.renoteCount,
      'replyCount': instance.replyCount,
      'attachments': instance.attachments,
      'renote': instance.renote,
      'notificationType': instance.notificationType,
      'isRead': instance.isRead,
      'notificationNote': instance.notificationNote,
      'emoji': instance.emoji,
      'mentions': instance.mentions
    };
