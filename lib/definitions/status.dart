import 'package:fedi/definitions/user.dart';
import 'package:fedi/definitions/file.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

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
  List<File> files;

  Status(id, date, author, url, title, body, visibility) {
    this.id = id;
    this.date = date;
    this.author = author;
    this.url = url;
    this.title = title;
    this.body = body;
    this.visibility = visibility.toLowerCase();
    this.files = files;
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
  }

  IconData visIcon() {
    switch (this.visibility) {
      case "public":
        return Icons.language;
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
