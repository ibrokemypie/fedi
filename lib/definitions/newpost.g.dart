// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'newpost.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewPost _$NewPostFromJson(Map<String, dynamic> json) {
  return NewPost(json['visiblity'],
      content: json['content'],
      contentWarning: json['contentWarning'],
      replyTo: json['replyTo']);
}

Map<String, dynamic> _$NewPostToJson(NewPost instance) => <String, dynamic>{
      'content': instance.content,
      'contentWarning': instance.contentWarning,
      'replyTo': instance.replyTo,
      'visiblity': instance.visiblity
    };
