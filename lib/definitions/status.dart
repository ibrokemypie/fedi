import 'package:fedi/definitions/user.dart';
import 'package:fedi/definitions/file.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import 'package:fedi/definitions/instance.dart';

part 'status.g.dart';

@JsonSerializable()
class Status {
  String id;
  String date;
  User author;
  String url;
  String title;
  String body;
  String visibility;
  bool favourited;
  String reaction;
  List<File> files;

  Status(id, date, author, url, title, body, visibility, favourited, reaction) {
    this.id = id;
    this.date = date;
    this.author = author;
    this.url = url;
    this.title = title;
    this.body = body;
    this.visibility = visibility.toLowerCase();
    this.files = files;
    this.favourited = favourited;
    this.reaction = reaction;
  }

  Status.fromJson(Map json) {
    this.id = json['id'];
    this.date = json['date'];
    this.author = json['author'];
    this.url = json['url'];
    this.title = json['title'];
    this.body = json['body'];
    this.visibility = json['visibility'].toString().toLowerCase();
    this.files = json['files'];
    this.favourited = json['favourited'];
    this.reaction = json['reaction'];
  }

  Status.fromMisskey(Map v, Instance instance) {
    if (v["user"] != null && v["id"] != null) {
      try {
        User user = new User.fromJson({
          "username": v["user"]["username"],
          "nickname": v["user"]["name"] ?? "null",
          "host": v["user"]["host"] ?? instance.host,
          "id": v["user"]["id"],
          "avatarUrl": v["user"]["avatarUrl"]
        });

        List<File> files = new List();
        for (var fileJson in v["files"]) {
          if (fileJson != null) {
            File newFile = new File.fromJson({
              "id": fileJson["id"],
              "date": fileJson["createdAt"],
              "name": fileJson["name"],
              "type": fileJson["type"],
              "authorId": fileJson["userId"],
              "sensitive": fileJson["isSensitive"],
              "thumbnailUrl": fileJson["thumbnailUrl"],
              "fileUrl": fileJson["url"],
            });
            files.add(newFile);
          }
        }

        if (v["renoteId"] != null) {
          this.author = user;
          this.title = "one";
          this.body = "Renote from " +
                  v["renote"]["user"]["username"] +
                  ": " +
                  v["renote"]["text"] ??
              "";
          this.id = v["id"];
          this.date = v["createdAt"];
          this.visibility = v["visibility"];
          this.url = v["uri"];
          this.files = files;
          this.favourited = v["isFavorited"] || v["myReaction"] != null;
        } else {
          this.author = user;
          this.title = "one";
          this.body = v["text"] ?? "";
          this.id = v["id"];
          this.date = v["createdAt"];
          this.visibility = v["visibility"];
          this.url = v["uri"];
          this.files = files;
          this.favourited = v["isFavorited"] || v["myReaction"] != null;
        }
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  IconData visIcon() {
    switch (this.visibility) {
      case "public":
        return Icons.public;
      case "home":
        return Icons.home;
      case "followers":
        return Icons.group;
      case "specified":
        return Icons.message;
    }
    return Icons.language;
  }

  Widget statusFiles() {
    switch (this.files.length) {
      case 0:
        return null;
      case 1:
        return Container(
          child: Image.network(
            this.files[0].thumbnailUrl,
            fit: BoxFit.contain,
          ),
        );
      case 2:
        return FittedBox(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.network(
              this.files[0].thumbnailUrl,
              fit: BoxFit.contain,
            ),
            Image.network(
              this.files[1].thumbnailUrl,
              fit: BoxFit.contain,
            ),
          ],
        ));
      case 3:
        return Column(children: <Widget>[
          FittedBox(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.network(
                this.files[0].thumbnailUrl,
                fit: BoxFit.contain,
              ),
              Image.network(
                this.files[1].thumbnailUrl,
                fit: BoxFit.contain,
              ),
            ],
          )),
          Container(
            child: Image.network(
              this.files[2].thumbnailUrl,
              fit: BoxFit.contain,
            ),
          ),
        ]);
      case 4:
        return Column(children: <Widget>[
          FittedBox(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.network(
                this.files[0].thumbnailUrl,
                fit: BoxFit.contain,
              ),
              Image.network(
                this.files[1].thumbnailUrl,
                fit: BoxFit.contain,
              ),
            ],
          )),
          FittedBox(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.network(
                this.files[2].thumbnailUrl,
                fit: BoxFit.contain,
              ),
              Image.network(
                this.files[3].thumbnailUrl,
                fit: BoxFit.contain,
              ),
            ],
          )),
        ]);
      default:
        return Column(children: <Widget>[
          FittedBox(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.network(
                this.files[0].thumbnailUrl,
                fit: BoxFit.contain,
              ),
              Image.network(
                this.files[1].thumbnailUrl,
                fit: BoxFit.contain,
              ),
            ],
          )),
          FittedBox(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.network(
                this.files[2].thumbnailUrl,
                fit: BoxFit.contain,
              ),
              Image.network(
                this.files[3].thumbnailUrl,
                fit: BoxFit.contain,
              ),
            ],
          )),
          Container(
            width: double.infinity,
            child: FlatButton(
              color: Colors.grey,
              onPressed: () => {},
              child: Center(child: Text("More")),
            ),
          ),
        ]);
    }
  }

  Map<String, dynamic> toJson() => _$StatusToJson(this);
}
