import 'package:fedi/definitions/user.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/definitions/item.dart';

part 'notification.g.dart';

@JsonSerializable()
class FediNotification {
  String id;
  String date;
  User author;
  String notificationType;
  bool isRead;
  Item note;

  FediNotification(id, date, author, notificationType, isRead, note) {
    this.id = id;
    this.date = date;
    this.author = author;
    this.notificationType = notificationType;
    this.isRead = isRead;
    this.note = note;
  }

  FediNotification.fromJson(Map json) {
    this.id = json['id'];
    this.date = json['date'];
    this.author = json['author'];
    this.notificationType = json['notificationType'];
    this.isRead = json['isRead'];
    this.note = json['note'];
  }

// TODO: notification from mastodon return
  FediNotification.fromMisskey(Map v, Instance instance) {
    this.id = v["id"];
    this.date = v["createdAt"];
    this.notificationType = v["type"];
    this.isRead = v["isRead"];
    this.author = User.fromMisskey(v["user"], instance) ?? null;
    this.note = Item.fromMisskey(v["note"], instance) ?? null;
  }

  Map<String, dynamic> toJson() => _$FediNotificationToJson(this);
}

Icon notificationTypeIcon(String notificationType) {
  switch (notificationType) {
    case "reply":
      return Icon(Icons.reply);
    case "renote":
      return Icon(Icons.repeat);
    case "reaction":
      return Icon(Icons.star);
    case "mention":
      return Icon(Icons.alternate_email);
  }
}

String notificationTypeString(String notificationType) {
  switch (notificationType) {
    case "reply":
      return " replied to your status.";
    case "renote":
      return " renoted your status.";
    case "reaction":
      return " favourited your status.";
    case "mention":
      return " mentioned you";
  }
  return "";
}
