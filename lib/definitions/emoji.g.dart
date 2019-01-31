// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Emoji _$EmojiFromJson(Map<String, dynamic> json) {
  return Emoji(json['url'], json['name'], json['shortcode'], json['aliases']);
}

Map<String, dynamic> _$EmojiToJson(Emoji instance) => <String, dynamic>{
      'url': instance.url,
      'name': instance.name,
      'shortcode': instance.shortcode,
      'aliases': instance.aliases
    };
