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

  User({username, nickname, id, host, avatarUrl, url}) {
    this.username = username?? "";
    this.nickname = nickname?? "";
    this.id = id?? "";
    this.host = host ?? "";
    this.avatarUrl = avatarUrl ?? "";
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

  User.fromMisskey(Map v, Instance instance) {
    this.username = v["username"];
    this.nickname = v["name"] ?? this.username;
    this.host = v["host"] ?? instance.host;
    this.acct = this.username + "@" + this.host;
    this.id = v["id"];
    this.url = this.host + "/@" + this.username;
    this.avatarUrl = v["avatarUrl"];
  }

  User.fromMastodon(Map v, Instance instance) {
    this.username = v["username"];
    this.nickname = v["display_name"] ?? this.username;
    this.host = v["host"] ?? instance.host;
    this.acct = v["acct"];
    this.id = v["id"];
    this.url = v["url"];
    this.avatarUrl = v["avatar"] ?? v["avatar_static"];
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
