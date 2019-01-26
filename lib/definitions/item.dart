import 'package:fedi/definitions/user.dart';
import 'package:fedi/definitions/file.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import 'package:fedi/definitions/instance.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  String id;
  String date;
  User author;
  String url;
  String title;
  String body;
  String visibility;
  bool favourited;
  int favCount;
  String myReaction;
  int renoteCount;
  List<File> files;
  Item renote;

  Item(id, date, author, url, title, body, visibility, favourited, favCount,
      myReaction, renoteCount, files, renote) {
    this.id = id;
    this.date = date;
    this.author = author;
    this.url = url;
    this.title = title;
    this.body = body;
    this.visibility = visibility.toLowerCase();
    this.favourited = favourited;
    this.favCount = favCount;
    this.myReaction = myReaction;
    this.renoteCount = renoteCount;
    this.files = files;
    this.renote = renote;
  }

  Item.fromJson(Map json) {
    this.id = json['id'];
    this.date = json['date'];
    this.author = json['author'];
    this.url = json['url'];
    this.title = json['title'];
    this.body = json['body'];
    this.visibility = json['visibility'].toString().toLowerCase();
    this.favourited = json['favourited'];
    this.favCount = json['favCount'];
    this.myReaction = json['reaction'];
    this.renoteCount = json['renoteCount'];
    this.files = json['files'];
    this.renote = json['renote'];
  }

// TODO: status from mastodon return
  Item.fromMisskey(Map v, Instance instance) {
    int countreacts(Map r) {
      int reactions = 0;
      r.forEach((react, number) => reactions += number);
      return reactions;
    }

    if (v["user"] != null && v["id"] != null && v["deletedAt"] == null) {
      try {
        List<File> files = new List();
        User user = new User.fromMisskey(v["user"], instance);

        for (var fileJson in v["files"]) {
          if (fileJson != null) {
            File newFile = File.fromMisskey(fileJson);
            files.add(newFile);
          }
        }

        if (v["renoteId"] != null && v["deletedAt"] == null) {
          this.renote = Item.fromMisskey(v["renote"], instance);
        }

        this.body = v["text"] ?? "";
        this.renoteCount = v["renoteCount"] ?? 0;
        this.files = files;
        this.myReaction = v["myReaction"] ?? null;
        this.id = v["id"];
        this.date = v["createdAt"];
        this.visibility = v["visibility"];
        this.url = v["uri"];
        this.files = files;
        this.favourited = v["isFavorited"] ?? (v["myReaction"] ?? false) ?? false;
        this.favCount = countreacts(v["reactionCounts"]);
        this.author = user;
        this.title = "one";
      } catch (e) {
        throw Exception(e);
      }
    }
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

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}

IconData visIcon(String visibility) {
  switch (visibility) {
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
