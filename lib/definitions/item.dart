import 'package:fedi/definitions/user.dart';
import 'package:fedi/definitions/file.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/definitions/emoji.dart';
import 'package:fedi/definitions/mention.dart';
import 'package:fedi/api/getuser.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  String id;
  String date;
  User author;
  String url;
  String contentWarning;
  String body;
  String visibility;
  bool favourited;
  int favCount;
  String myReaction;
  int renoteCount;
  int replyCount;
  List<File> files;
  Item renote;
  String notificationType;
  bool isRead;
  Item notificationNote;
  List<Emoji> emoji;
  List<Mention> mentions;

  Item(
      id,
      date,
      author,
      url,
      contentWarning,
      body,
      visibility,
      favourited,
      favCount,
      myReaction,
      renoteCount,
      replyCount,
      files,
      renote,
      notificationType,
      isRead,
      notificationNote,
      emoji,
      mentions) {
    this.id = id;
    this.date = date;
    this.author = author;
    this.url = url;
    this.contentWarning = contentWarning;
    this.body = body;
    this.visibility = visibility.toLowerCase();
    this.favourited = favourited;
    this.favCount = favCount;
    this.myReaction = myReaction;
    this.renoteCount = renoteCount;
    this.replyCount = replyCount;
    this.files = files;
    this.renote = renote;
    this.notificationType = notificationType;
    this.isRead = isRead;
    this.notificationNote = notificationNote;
    this.emoji = emoji;
    this.mentions = mentions;
  }

  Item.fromJson(Map json) {
    this.id = json['id'];
    this.date = json['date'];
    this.author = json['author'];
    this.url = json['url'];
    this.contentWarning = json['cw'];
    this.body = json['body'];
    this.visibility = json['visibility'].toString().toLowerCase();
    this.favourited = json['favourited'];
    this.favCount = json['favCount'];
    this.myReaction = json['reaction'];
    this.renoteCount = json['renoteCount'];
    this.replyCount = json['replyCount'];
    this.files = json['files'];
    this.renote = json['renote'];
    this.notificationType = json['notificationType'];
    this.isRead = json['isRead'];
    this.notificationNote = json['notificationNote'];
    this.emoji = json['emoji'];
    this.mentions = json['mentions'];
  }

  Item.fromMisskey(Map v, Instance instance) {
    int countreacts(Map r) {
      int reactions = 0;
      if (r != null) {
        r.forEach((react, number) => reactions += number);
      }
      return reactions;
    }

    if (v["user"] != null &&
        v["id"] != null &&
        v["deletedAt"] == null &&
        !v.containsKey("deletedAt")) {
      try {
        List<File> files = new List();
        List<Emoji> postEmojis = List<Emoji>();
        List<Mention> mentions = List<Mention>();
        List emojis = v["emojis"] ?? [];

        if (emojis.length > 0) {
          for (var emoji in emojis) {
            if (emoji != null) {
              Emoji newEmoji = Emoji.fromMisskey(emoji);
              postEmojis.add(newEmoji);
            }
          }
        }

        if (v["files"] != null) {
          for (var fileJson in v["files"]) {
            if (fileJson != null) {
              File newFile = File.fromMisskey(fileJson);
              files.add(newFile);
            }
          }
        }

        if (v["renoteId"] != null && v["deletedAt"] == null) {
          this.renote = Item.fromMisskey(v["renote"], instance);
        }

        if (v["user"] != null) {
          User user = new User.fromMisskey(v["user"], instance);
          this.author = user;
        }

        if (v["mentions"] != null) {
          for (String mentionedId in v["mentions"]) {
            mentions.add(Mention(id: mentionedId));
          }
        }
        // if (v["mentionedRemoteUsers"] != null) {
        //   for (Map mentionJson in v["mentionedRemoteUsers"]) {
        //     mentions.add(Mention.fromMisskey(mentionJson));
        //   }
        // }

        this.id = v["id"];
        this.date = v["createdAt"];
        this.body = v["text"] ?? "";
        this.renoteCount = v["renoteCount"] ?? 0;
        this.replyCount = v["repliesCount"] ?? 0;
        this.files = files;
        this.myReaction = v["myReaction"] ?? null;
        this.visibility = v["visibility"] ?? null;
        this.url = v["uri"];
        this.files = files;
        this.emoji = postEmojis;
        this.favourited =
            v["isFavorited"] ?? (v["myReaction"] ?? false) ?? false;
        this.favCount = countreacts(v["reactionCounts"]) ?? null;
        this.contentWarning = v["cw"] ?? null;
        this.mentions = mentions;

        if (v["type"] != null && v["deletedAt"] == null) {
          this.isRead = v["isRead"];
          this.notificationType = v["type"];
          if (v["note"] != null) {
            this.notificationNote = Item.fromMisskey(v["note"], instance);
          }
        }
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  Item.fromMastodon(Map v, Instance instance) {
    if (v["account"] != null && v["id"] != null) {
      try {
        List<File> files = new List();
        List attachments = v["media_attachments"] ?? [];
        List<Emoji> postEmojis = List<Emoji>();
        List emojis = v["emojis"] ?? [];
        List<Mention> mentions = List<Mention>();

        if (emojis.length > 0) {
          for (var emoji in emojis) {
            if (emoji != null) {
              Emoji newEmoji = Emoji.fromMastodon(emoji);
              postEmojis.add(newEmoji);
            }
          }
        }

        if (attachments.length > 0) {
          for (var fileJson in attachments) {
            if (fileJson != null) {
              File newFile = File.fromMastodon(fileJson, v["sensitive"]);
              files.add(newFile);
            }
          }
        }

        if (v["reblog"] != null) {
          this.renote = Item.fromMastodon(v["reblog"], instance);
        }

        if (v["account"] != null) {
          User user = new User.fromMastodon(v["account"], instance);
          this.author = user;
        }

        if (v["mentions"] != null) {
          for (Map mentionMap in v["mentions"]) {
            mentions.add(Mention.fromMastodon(mentionMap));
          }
        }

        this.id = v["id"];
        this.date = v["created_at"];
        this.body = v["content"] ?? "";
        this.renoteCount = v["reblogs_count"] ?? 0;
        this.replyCount = v["replies_count"] ?? 0;
        this.files = files;
        this.emoji = postEmojis;
        this.myReaction = null;
        this.visibility = v["visibility"] ?? null;
        this.url = v["url"];
        this.favourited = v["favourited"] ?? false;
        this.favCount = v["favourites_count"];
        this.contentWarning = v["spoiler_text"] ?? null;
        this.mentions = mentions;

        if (v["type"] != null) {
          this.notificationType = v["type"];
          if (v["status"] != null) {
            this.notificationNote = Item.fromMastodon(v["status"], instance);
          }
        }
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}

IconData visIcon(String visibility) {
  switch (visibility) {
    case "public":
      return Icons.public;
    case "home":
    case "unlisted":
      return Icons.home;
    case "followers":
    case "private":
      return Icons.group;
    case "specified":
      return Icons.message;
  }
  return Icons.language;
}

Icon notificationTypeIcon(String notificationType) {
  switch (notificationType) {
    case "reply":
      return Icon(Icons.reply);
    case "renote":
    case "reblog":
      return Icon(Icons.repeat);
    case "reaction":
    case "favourite":
      return Icon(Icons.star);
    case "mention":
      return Icon(Icons.alternate_email);
    case "follow":
      return Icon(Icons.person_add);
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
    case "follow":
      return " followed you";
  }
  return "";
}
