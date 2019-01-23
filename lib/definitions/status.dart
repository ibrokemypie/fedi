import 'package:fedi/definitions/user.dart';
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

  Status(id, date, author, url, title, body, visibility) {
    this.id = id;
    this.date = date;
    this.author = author;
    this.url = url;
    this.title = title;
    this.body = body;
    this.visibility = visibility.toLowerCase();
  }

  Status.fromJson(Map json) {
    this.id = json['id'];
    this.date = json['date'];
    this.author = json['author'];
    this.url = json['url'];
    this.title = json['title'];
    this.body = json['body'];
    this.visibility = json['visibility'].toString().toLowerCase();
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

  Map<String, dynamic> toJson() => _$StatusToJson(this);
}
