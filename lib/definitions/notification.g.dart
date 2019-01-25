// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FediNotification _$FediNotificationFromJson(Map<String, dynamic> json) {
  return FediNotification(json['id'], json['date'], json['author'],
      json['notificationType'], json['isRead'], json['note']);
}

Map<String, dynamic> _$FediNotificationToJson(FediNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'author': instance.author,
      'notificationType': instance.notificationType,
      'isRead': instance.isRead,
      'note': instance.note
    };
