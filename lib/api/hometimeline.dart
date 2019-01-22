import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fedi/definitions/status.dart';
import 'package:fedi/definitions/user.dart';

getHomeTimeline(Instance instance, String authCode) async {
  List statuses;
  switch (instance.type) {
    case "misskey":
      {
        statuses = await getMisskeyHomeTimeline(instance, authCode);
        break;
      }
    default:
      {
        throw Exception(instance.type + " isnt supported lol");
      }
  }
  return statuses;
}

Future<List> getMisskeyHomeTimeline(Instance instance, String authCode) async {
  List statuses = new List();
  String actionPath = "/api/notes/timeline";
  Map<String, dynamic> params = Map.from({
    "limit": 40,
    "i": authCode,
  });

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));

  if (response.statusCode == 200) {
    List<dynamic> returned = json.decode(response.body);

    returned.forEach((v) {
      Status status;
      try {
        User user = new User.fromJson({
          "username": v["user"]["username"],
          "nickname": v["user"]["name"] ?? "null",
          "host": v["user"]["host"] ?? instance.host,
          "id": v["user"]["id"],
          "avatarUrl": v["user"]["avatarUrl"]
        });

        if (v["renoteId"] != null) {
          status = Status.fromJson({
            "author": user,
            "title": "one",
            "body": "Renote from " + v["renote"]["user"]["username"] + ": " + v["renote"]["text"],
            "id": v["renoteId"],
            "date": v["createdAt"],
            "visibility": v["visibility"],
            "url": v["uri"]
          });
        } else {
          status = Status.fromJson({
            "author": user,
            "title": "one",
            "body": v["text"],
            "id": v["id"],
            "date": v["createdAt"],
            "visibility": v["visibility"],
            "url": v["uri"]
          });
        }
        print(status.toJson());
        statuses.add(status);
      } catch (e) {
        print(e);
      }
    });

    return statuses;
  } else {
    throw Exception('Failed to load post');
  }
}
