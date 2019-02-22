import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:fedi/definitions/emoji.dart';

part 'instance.g.dart';

@JsonSerializable()
class Instance {
  String type;
  String uri;
  String title;
  String description;
  String version;
  String protocol;
  String host;
  int maxChars;
  List<Emoji> emojiList;

  Instance(this.uri, this.protocol, this.host, this.title, this.description,
      this.version,
      [this.type]) {
    String version = this.version.toLowerCase();
    if (this.type == null) {
      if (version.contains("misskey")) {
        this.type = "misskey";

        // TODO: change things for pleroma
      } else if (version.contains("pleroma")) {
        this.type = "mastodon";
      } else {
        this.type = "mastodon";
      }
    }
  }

  Instance.fromMisskey(Map json) {
    this.type = "misskey";
    this.uri = json["uri"];
    this.title = json["name"];
    this.description = json["description"];
    this.version = json["version"];
    this.protocol = Uri.parse(this.uri).scheme;
    this.host = Uri.parse(this.uri).host;
    this.maxChars = json["maxNoteTextLength"] ?? 500;
    this.emojiList =
        json["emojis"].map<Emoji>((emoji) => Emoji.fromMisskey(emoji)).toList();
  }

  Instance.fromMastodon(Map json, List<Emoji> instanceEmoji, Uri originalUri) {
    this.type = "mastodon";
    this.uri = originalUri.toString();
    this.title = json["title"];
    this.description = json["description"];
    this.version = json["version"];
    this.protocol = originalUri.scheme;
    this.host = originalUri.host;
    this.maxChars = json["max_toot_chars"] ?? json["maxNoteTextLength"] ?? 500;
    this.emojiList = instanceEmoji ?? null;
  }

  static Future<Instance> fromUrl(String instanceUrl) async {
    try {
      String protocol;
      if (instanceUrl.startsWith('http://')) {
        protocol = "http://";
      } else {
        protocol = "https://";
      }

      Uri instanceUri = Uri.parse(protocol + instanceUrl);
      Instance newInstance;

      // First try misskey
      final misskeyResponse =
          await http.post(instanceUri.toString() + "/api/meta");

      if (misskeyResponse.statusCode == 200) {
        Map<String, dynamic> instanceJson = json.decode(misskeyResponse.body);
        newInstance = Instance.fromMisskey(instanceJson);

        // If error is 404, try mastodon
      } else if (misskeyResponse.statusCode == 404 ||
          misskeyResponse.statusCode == 422) {
        final mastodonResponse =
            await http.get(instanceUri.toString() + "/api/v1/instance");

        if (mastodonResponse.statusCode == 200) {
          List<Emoji> instanceEmoji;

          Map<String, dynamic> instanceJson =
              json.decode(mastodonResponse.body);

          final emojiResponse =
              await http.get(instanceUri.toString() + "/api/v1/custom_emojis");
          if (emojiResponse.statusCode == 200) {
            List emojiJsonJson = json.decode(emojiResponse.body);
            instanceEmoji = emojiJsonJson
                .map<Emoji>((emoji) => Emoji.fromMastodon(emoji))
                .toList();
          }

          newInstance =
              Instance.fromMastodon(instanceJson, instanceEmoji, instanceUri);
        } else {
          throw Exception(mastodonResponse);
        }
      } else {
        throw Exception(misskeyResponse);
      }

      return (newInstance);
    } catch (exception) {
      throw exception;
    }
  }

  factory Instance.fromJson(Map<String, dynamic> json) =>
      _$InstanceFromJson(json);

  Map<String, dynamic> toJson() => _$InstanceToJson(this);
}
