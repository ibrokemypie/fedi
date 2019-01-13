import 'package:flutter/material.dart';
import 'package:recase/recase.dart';
import 'user.dart';

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

Widget statusBuilder(Status status) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Avatar
        Container(
          alignment: FractionalOffset.topCenter,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(status.author.avatarUrl),
          ),
        ),

        // Content
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Author
            Container(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(children: <Widget>[
                // Nickname
                Container(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    status.author.nickname,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Account name
                Text(status.author.acct),
              ]),
            ),

            // Body
            Container(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(status.body),
            ),

            // Body
            Container(
              child: Text(status.visibility),
            ),

            // Buttons
            Row(
              children: <Widget>[
                // Reply
                Row(children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.reply),
                    onPressed: null,
                  ),
                  Text("0"),
                ]),

                // Boost
                Row(children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.repeat),
                    onPressed: null,
                  ),
                  Text("0"),
                ]),

                // Favourite
                Row(children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.star),
                    onPressed: null,
                  ),
                  Text("0"),
                ]),
              ],
            ),
          ],
        )),
      ],
    ),
  );
}
