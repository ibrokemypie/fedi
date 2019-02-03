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
  String bannerUrl;
  String url;
  String acct;
  String description;
  List<Map<String, dynamic>> fields;
  int followersCount;
  int followingCount;
  int statusCount;

  User(
      {username,
      nickname,
      id,
      host,
      avatarUrl,
      bannerUrl,
      url,
      description,
      fields,
      followersCount,
      followingCount,
      statusCount}) {
    this.username = username ?? "";
    this.nickname = nickname ?? "";
    this.id = id ?? "";
    this.host = host ?? "";
    this.avatarUrl = avatarUrl ?? "";
    this.bannerUrl = bannerUrl ?? "";
    this.url = this.host + "/@" + this.username;
    this.acct = this.username + "@" + this.host;
    this.description = this.description ?? "";
    this.fields = this.fields ?? List();
    this.followersCount = this.followersCount;
    this.followingCount = this.followingCount;
    this.statusCount = this.statusCount;
  }

  User.fromJson(Map json) {
    this.username = json['username'];
    this.nickname = json['nickname'];
    this.id = json['id'];
    this.host = json['host'];
    this.avatarUrl = json['avatarUrl'];
    this.bannerUrl = json['bannerUrl'];
    this.url = this.host + "/@" + this.username;
    this.acct = this.username + "@" + this.host;
    this.description = json['description'];
    this.fields = json['fields'];
    this.followersCount = json['followersCount'];
    this.followingCount = json['followingCount'];
    this.statusCount = json['statusCount'];
  }

  User.fromMisskey(Map v, Instance instance) {
    List<Map<String, dynamic>> newFields = new List();
    List jsonFields = v["fields"] ?? [];

    if (jsonFields.length > 0) {
      for (Map<String, dynamic> field in jsonFields) {
        if (field != null) {
          newFields.add(field);
        }
      }
    }

    this.username = v["username"];
    this.nickname = v["name"] ?? this.username;
    this.host = v["host"] ?? instance.host;
    this.acct = this.username + "@" + this.host;
    this.id = v["id"];
    this.url = this.host + "/@" + this.username;
    this.avatarUrl = v["avatarUrl"] ?? "";
    this.bannerUrl = v["bannerUrl"] ?? "";
    this.description = v["description"] ?? "";
    this.fields = newFields;
    this.followersCount = v['followersCount'];
    this.followingCount = v['followingCount'];
    this.statusCount = v['notesCount'];

    this.description = this.description.replaceAll("\n", "<br>");
  }

  User.fromMastodon(Map v, Instance instance) {
    List<Map<String, dynamic>> newFields = new List();
    List jsonFields = v["fields"] ?? [];

    if (jsonFields.length > 0) {
      for (Map<String, dynamic> field in jsonFields) {
        if (field != null) {
          newFields.add(field);
        }
      }
    }

    this.username = v["username"];
    this.nickname = v["display_name"] ?? this.username;
    this.host = v["host"] ?? instance.host;
    this.acct = v["acct"];
    this.id = v["id"];
    this.url = v["url"];
    this.avatarUrl = v["avatar"] ?? v["avatar_static"] ?? "";
    this.bannerUrl = v["header"] ?? v["header_static"] ?? "";
    this.description = v["note"];
    this.fields = newFields;
    this.followersCount = v['followers_count'];
    this.followingCount = v['following_count'];
    this.statusCount = v['statuses_count'];
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
