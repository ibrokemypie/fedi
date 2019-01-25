import 'package:json_annotation/json_annotation.dart';
import 'package:fedi/definitions/instance.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  String username;
  String nickname;
  String id;
  String host;
  String avatarUrl;
  String url;
  String acct;

  User(username, nickname, id, host, avatarUrl, url) {
    this.username = username;
    this.nickname = nickname;
    this.id = id;
    this.host = host;
    this.avatarUrl = avatarUrl;
    this.url = this.host + "/@" + this.username;
    this.acct = this.username + "@" + this.host;
  }

  User.fromJson(Map json) {
    this.username = json['username'];
    this.nickname = json['nickname'];
    this.id = json['id'];
    this.host = json['host'];
    this.avatarUrl = json['avatarUrl'];
    this.url = this.host + "/@" + this.username;
    this.acct = this.username + "@" + this.host;
  }

// TODO: user from mastodon return
  User.fromMisskey(Map v, Instance instance) {
    this.username = v["user"]["username"];
    this.nickname = v["user"]["name"] ?? "null";
    this.host = v["user"]["host"] ?? instance.host;
    this.acct = this.username + "@" + this.host;
    this.id = v["user"]["id"];
    this.url = this.host + "/@" + this.username;
    this.avatarUrl = v["user"]["avatarUrl"];
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
