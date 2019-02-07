import 'package:fedi/definitions/user.dart';
import 'package:fedi/definitions/attachment.dart';
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
  String remoteUrl;
  String localUrl;
  String contentWarning;
  String body;
  String visibility;
  bool favourited;
  int favCount;
  String myReaction;
  int renoteCount;
  int replyCount;
  List<Attachment> attachments;
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
      remoteUrl,
      localUrl,
      contentWarning,
      body,
      visibility,
      favourited,
      favCount,
      myReaction,
      renoteCount,
      replyCount,
      attachments,
      renote,
      notificationType,
      isRead,
      notificationNote,
      emoji,
      mentions) {
    this.id = id;
    this.date = date;
    this.author = author;
    this.remoteUrl = remoteUrl;
    this.localUrl = localUrl;
    this.contentWarning = contentWarning;
    this.body = body;
    this.visibility = visibility.toLowerCase();
    this.favourited = favourited;
    this.favCount = favCount;
    this.myReaction = myReaction;
    this.renoteCount = renoteCount;
    this.replyCount = replyCount;
    this.attachments = attachments;
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
    this.remoteUrl = json['remoteUrl'];
    this.localUrl = json['localUrl'];
    this.contentWarning = json['cw'];
    this.body = json['body'];
    this.visibility = json['visibility'].toString().toLowerCase();
    this.favourited = json['favourited'];
    this.favCount = json['favCount'];
    this.myReaction = json['reaction'];
    this.renoteCount = json['renoteCount'];
    this.replyCount = json['replyCount'];
    this.attachments = json['attachments'];
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
        !v.containsKey("deletedAt") &&
        !(v["note"] != null && v["note"].containsKey("deletedAt"))) {
      try {
        List<Attachment> attachments = new List();
        List jsonAttachments = v["media"] ?? [];
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

        if (jsonAttachments.length > 0) {
          for (var AttachmentJson in jsonAttachments) {
            if (AttachmentJson != null) {
              Attachment newAttachment = Attachment.fromMisskey(AttachmentJson);
              attachments.add(newAttachment);
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
        this.attachments = attachments;
        this.myReaction = v["myReaction"] ?? null;
        this.visibility = v["visibility"] ?? null;
        this.remoteUrl = v["uri"];
        this.localUrl = instance.uri + "/notes/" + this.id;
        this.attachments = attachments;
        this.emoji = postEmojis;
        this.favourited =
            v["isFavorited"] ?? (v["myReaction"] != null) ?? false;
        this.favCount = countreacts(v["reactionCounts"]) ?? null;
        this.contentWarning = v["cw"] ?? null;
        this.mentions = mentions;

        this.body = this.body.replaceAll("\n", "<br>");

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
    if (v["account"] != null &&
        v["id"] != null &&
        !(v["note"] != null && v["status"].containsKey("deleted_at"))) {
      try {
        List<Attachment> attachments = new List();
        List jsonAttachments = v["media_attachments"] ?? [];
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

        if (jsonAttachments.length > 0) {
          for (var AttachmentJson in jsonAttachments) {
            if (AttachmentJson != null) {
              Attachment newAttachment =
                  Attachment.fromMastodon(AttachmentJson, v["sensitive"]);
              attachments.add(newAttachment);
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
            mentions.add(Mention.fromMastodon(mentionMap, instance));
          }
        }

        this.id = v["id"];
        this.date = v["created_at"];
        this.body = v["content"] ?? "";
        this.renoteCount = v["reblogs_count"] ?? 0;
        this.replyCount = v["replies_count"] ?? 0;
        this.attachments = attachments;
        this.emoji = postEmojis;
        this.myReaction = null;
        this.visibility = v["visibility"] ?? null;
        this.remoteUrl = v["url"];
        this.localUrl =
            instance.uri + "/users/" + author.username + "/statuses/" + this.id;
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
