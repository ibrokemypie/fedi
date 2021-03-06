import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/definitions/shared.dart';
import 'package:tuple/tuple.dart';

Future<Tuple3> getTimeline(
    Instance instance, String authCode, String timelineName,
    {List<Item> currentStatuses,
    bool sinceId = false,
    bool untilId = false,
    String targetUserId}) async {
  Tuple3 statuses;

  switch (instance.type) {
    case "misskey":
      {
        statuses = await getMisskeyTimeline(instance, authCode, timelineName,
            currentStatuses: currentStatuses,
            sinceId: sinceId,
            untilId: untilId,
            targetUserId: targetUserId);
        break;
      }
    case "mastodon":
      {
        statuses = await getMastodonTimeline(instance, authCode, timelineName,
            currentStatuses: currentStatuses,
            sinceId: sinceId,
            untilId: untilId,
            targetUserId: targetUserId);
        break;
      }
    default:
      {
        throw (instance.type + "not supported");
      }
  }
  return statuses;
}

Future<Tuple3> getMisskeyTimeline(
    Instance instance, String authCode, String timelineName,
    {List<Item> currentStatuses,
    bool sinceId,
    bool untilId,
    String targetUserId}) async {
  List<Item> newStatuses = new List();
  Map<String, dynamic> params = new Map();
  String actionPath;

  params = Map.from({
    "limit": 40,
    "i": authCode,
  });

  if (currentStatuses != null && currentStatuses.length > 0) {
    if (sinceId) {
      params.addAll({"sinceId": currentStatuses[1].id});
    }

    if (untilId) {
      params.addAll({"untilId": currentStatuses.last.id});
    }
  }

  switch (timelineName) {
    case "home":
      actionPath = "/api/notes/timeline";
      break;
    case "local":
      actionPath = "/api/notes/local-timeline";
      break;
    case "public":
      actionPath = "/api/notes/global-timeline";
      break;
    case "notifications":
      actionPath = "/api/i/notifications";
      break;
    case "user":
      actionPath = "/api/users/notes";
      params.addAll({"userId": targetUserId});
      break;
    case "user_media":
      actionPath = "/api/users/notes";
      params.addAll({"userId": targetUserId, "withFiles": true});
      break;
    case "user_replies":
      actionPath = "/api/users/notes";
      params.addAll({"userId": targetUserId, "includeReplies": true});
      break;
  }

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));

  if (response.statusCode == 200) {
    List<dynamic> returned = json.decode(response.body);

    returned.forEach((v) {
      var status = Item.fromMisskey(v, instance);
      if (status != null && status.id != null) newStatuses.add(status);
    });

    List<Item> toReturn;
    String newestId;
    String oldestId;

    if (currentStatuses != null && currentStatuses.length > 0) {
      if (sinceId) {
        if (newStatuses.length > 0) {
          if (newStatuses.first.id == currentStatuses.first.id) {
            newStatuses.removeAt(0);
          } else {
            newestId = newStatuses.last.id;
            oldestId = newStatuses.first.id;
          }
        }
        toReturn = new List<Item>.from(newStatuses.reversed)
          ..addAll(currentStatuses);
      } else {
        toReturn = new List<Item>.from(currentStatuses)..addAll(newStatuses);
      }
    } else {
      toReturn = newStatuses;
    }

    return Tuple3<List<Item>, String, String>(toReturn, newestId, oldestId);
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}

Future<Tuple3> getMastodonTimeline(
    Instance instance, String authCode, String timelineName,
    {List<Item> currentStatuses,
    bool sinceId,
    bool untilId,
    String targetUserId}) async {
  List<Item> newStatuses = new List();
  Map<String, dynamic> params;
  String actionPath;

  params = Map.from({
    "limit": "40",
  });

  if (currentStatuses != null && currentStatuses.length > 0) {
    if (sinceId) {
      params.addAll({"since_id": currentStatuses[1].id});
    }

    if (untilId) {
      params.addAll({"max_id": currentStatuses.last.id});
    }
  }

  switch (timelineName) {
    case "home":
      actionPath = "/api/v1/timelines/home";
      break;
    case "local":
      actionPath = "/api/v1/timelines/public";
      params.addAll({"local": "true"});
      break;
    case "public":
      actionPath = "/api/v1/timelines/public";
      break;
    case "notifications":
      actionPath = "/api/v1/notifications";
      break;
    case "user":
      actionPath = "/api/v1/accounts/" + targetUserId + "/statuses";
      params.addAll({"exclude_replies": "true"});
      break;
    case "user_media":
      actionPath = "/api/v1/accounts/" + targetUserId + "/statuses";
      params.addAll({"only_media": "true"});
      break;
    case "user_replies":
      actionPath = "/api/v1/accounts/" + targetUserId + "/statuses";
      params.addAll({"exclude_replies": "false"});
      break;
    case "user_pinned":
      actionPath = "/api/v1/accounts/" + targetUserId + "/statuses";
      params.addAll({"pinned": "true"});
      break;
  }

  final response = await http.get(
      instance.uri + actionPath + "?" + uriEncodeMap(params),
      headers: {"Authorization": "bearer " + authCode});

  if (response.statusCode == 200) {
    List<dynamic> returned = json.decode(response.body);

    returned.forEach((v) {
      var status = Item.fromMastodon(v, instance);
      if (status != null) newStatuses.add(status);
    });

    List<Item> toReturn;
    String newestId;
    String oldestId;

    if (currentStatuses != null && currentStatuses.length > 0) {
      if (sinceId) {
        if (newStatuses.length > 0) {
          if (newStatuses.first.id == currentStatuses.first.id) {
            newStatuses.removeAt(0);
          } else {
            newestId = newStatuses.last.id;
            oldestId = newStatuses.first.id;
          }
        }
        toReturn = new List<Item>.from(newStatuses.reversed)
          ..addAll(currentStatuses);
      } else {
        toReturn = new List<Item>.from(currentStatuses)..addAll(newStatuses);
      }
    } else {
      toReturn = newStatuses;
    }

    return Tuple3<List<Item>, String, String>(toReturn, newestId, oldestId);
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}
