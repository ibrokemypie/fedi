import 'package:recase/recase.dart';
import 'package:fedi/definitions/user.dart';

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
    this.visibility = ReCase(visibility).titleCase;
  }

  Status.fromJson(Map json) {
    this.id = json['id'];
    this.date = json['date'];
    this.author = json['author'];
    this.url = json['url'];
    this.title = json['title'];
    this.body = json['body'];
    this.visibility = ReCase(json['visibility']).titleCase;
  }
}
