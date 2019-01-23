// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

File _$FileFromJson(Map<String, dynamic> json) {
  return File(
      json['id'],
      json['date'],
      json['name'],
      json['type'],
      json['authorId'],
      json['sensitive'],
      json['thumbnailUrl'],
      json['fileUrl']);
}

Map<String, dynamic> _$FileToJson(File instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'name': instance.name,
      'type': instance.type,
      'authorId': instance.authorId,
      'sensitive': instance.sensitive,
      'thumbnailUrl': instance.thumbnailUrl,
      'fileUrl': instance.fileUrl
    };
