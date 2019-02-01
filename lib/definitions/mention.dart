import 'package:json_annotation/json_annotation.dart';
import 'package:fedi/definitions/instance.dart';

part 'mention.g.dart';

@JsonSerializable()
class Mention {
  String id;
  String username;
  String host;
  String acct;
  String url;

  Mention({id, username, host, acct, url}) {
    this.id = id;
    this.username = username;
    this.host = host;
    this.acct = acct;
    this.url = url;
  }

  Mention.fromMisskey(Map json) {
    this.id = json['id'] ?? null;
    this.username = json['username'] ?? null;
    this.url = json['uri'] ?? null;
    this.host = json['host'] ?? null;
    if (this.username != null && this.host != null) {
      this.acct = this.username + "@" + this.host;
    } else {
      this.host = null;
    }
  }

  Mention.fromMastodon(Map json, Instance instance) {
    this.id = json['id'];
    this.username = json['username'];
    this.url = json['url'];
    this.acct = json['acct'];
    if (this.acct.split("@").length > 1) {
      this.host = this.acct.split("@")[1];
    } else {
      this.host = instance.host;
    }
  }

  Map<String, dynamic> toJson() => _$MentionToJson(this);
  factory Mention.fromJson(Map<String, dynamic> json) =>
      _$MentionFromJson(json);
}
