// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attachment _$AttachmentFromJson(Map<String, dynamic> json) {
  return Attachment(
      json['id'],
      json['date'],
      json['name'],
      json['type'],
      json['authorId'],
      json['sensitive'],
      json['thumbnailUrl'],
      json['fileUrl']);
}

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'name': instance.name,
      'type': instance.type,
      'authorId': instance.authorId,
      'sensitive': instance.sensitive,
      'thumbnailUrl': instance.thumbnailUrl,
      'fileUrl': instance.fileUrl
    };
