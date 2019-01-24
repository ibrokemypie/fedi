import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fedi/definitions/status.dart';
import 'package:fedi/definitions/user.dart';
import 'package:fedi/definitions/file.dart';

getHomeTimeline(Instance instance, String authCode,
    {List<Status> currentStatuses, String sinceId}) async {
  List<Status> statuses;

  switch (instance.type) {
    case "misskey":
      {
        statuses = await getMisskeyHomeTimeline(instance, authCode,
            currentStatuses: currentStatuses, sinceId: sinceId);
        break;
      }
    default:
      {
        throw Exception(instance.type + " isnt supported lol");
      }
  }
  return statuses;
}

Future<List> getMisskeyHomeTimeline(Instance instance, String authCode,
    {List<Status> currentStatuses, String sinceId}) async {
  List<Status> newStatuses = new List();
  Map<String, dynamic> params;
  String actionPath = "/api/notes/timeline";

  if (sinceId == null) {
    params = Map.from({
      "limit": 40,
      "i": authCode,
    });
  } else {
    params = Map.from({
      "limit": 40,
      "i": authCode,
      "SinceId": sinceId,
    });
  }

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));

  if (response.statusCode == 200) {
    List<dynamic> returned = json.decode(response.body);

    returned.forEach((v) {
      Status status;
      if (v["user"] != null && v["id"] != null) {
        try {
          User user = new User.fromJson({
            "username": v["user"]["username"],
            "nickname": v["user"]["name"] ?? "null",
            "host": v["user"]["host"] ?? instance.host,
            "id": v["user"]["id"],
            "avatarUrl": v["user"]["avatarUrl"]
          });

          List<File> files = new List();
          for (var fileJson in v["files"]) {
            if (fileJson != null) {
              File newFile = new File.fromJson({
                "id": fileJson["id"],
                "date": fileJson["createdAt"],
                "name": fileJson["name"],
                "type": fileJson["type"],
                "authorId": fileJson["userId"],
                "sensitive": fileJson["isSensitive"],
                "thumbnailUrl": fileJson["thumbnailUrl"],
                "fileUrl": fileJson["url"],
              });
              files.add(newFile);
            }
          }

          if (v["renoteId"] != null) {
            status = Status.fromJson({
              "author": user,
              "title": "one",
              "body": "Renote from " +
                      v["renote"]["user"]["username"] +
                      ": " +
                      v["renote"]["text"] ??
                  "",
              "id": v["renoteId"],
              "date": v["createdAt"],
              "visibility": v["visibility"],
              "url": v["uri"],
              "files": files,
            });
          } else {
            status = Status.fromJson({
              "author": user,
              "title": "one",
              "body": v["text"] ?? "",
              "id": v["id"],
              "date": v["createdAt"],
              "visibility": v["visibility"],
              "url": v["uri"],
              "files": files,
            });
          }
          newStatuses.add(status);
        } catch (e) {
          throw Exception(e);
        }
      }
    });

    if (currentStatuses != null) {
      return new List<Status>.from(newStatuses)..addAll(currentStatuses);
    }

    return newStatuses;
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}
