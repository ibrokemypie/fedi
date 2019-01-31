import 'package:json_annotation/json_annotation.dart';

part 'emoji.g.dart';

@JsonSerializable()
class Emoji {
  String url;
  String name;
  String shortcode;
  List aliases;

  Emoji(url, name, shortcode, aliases) {
    this.url = url;
    this.name = name;
    this.shortcode = shortcode;
  }

  Emoji.fromJson(Map json) {
    this.url = json['url'];
    this.name = json['name'];
    this.shortcode = json['shortcode'];
    this.aliases = json['aliases'];
  }

  Emoji.fromMisskey(Map json) {
    this.url = json['url'];
    this.name = json['name'];
    this.shortcode = ":" + json['name'] + ":";
    this.aliases = json['aliases'] ?? null;
  }

  Emoji.fromMastodon(Map json) {
    this.url = json['url'];
    this.name = json['shortcode'].toString().replaceAll(":", "");
    this.shortcode = json['shortcode'];
    this.aliases = null;
  }

  Map<String, dynamic> toJson() => _$EmojiToJson(this);
}
