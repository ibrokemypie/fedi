import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fedi/definitions/item.dart';

Future<List<Item>> getTimeline(Instance instance, String authCode, String timelineName,
    {List<Item> currentStatuses, String sinceId}) async {
  List<Item> statuses;


  switch (instance.type) {
    case "misskey":
      {
        statuses = await getMisskeyTimeline(instance, authCode, timelineName,
            currentStatuses: currentStatuses, sinceId: sinceId);
        break;
      }
    // TODO: get Publictimeline on mastodon
    default:
      {
        throw Exception(instance.type + " isnt supported lol");
      }
  }
  return statuses;
}

Future<List> getMisskeyTimeline(Instance instance, String authCode, String timelineName,
    {List<Item> currentStatuses, String sinceId}) async {
  List<Item> newStatuses = new List();
  Map<String, dynamic> params;
    String actionPath;


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
  }

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
        var status = Item.fromMisskey(v, instance);
        if (status != null)
          newStatuses.add(status);
    });

    if (currentStatuses != null) {
      return new List<Item>.from(newStatuses)..addAll(currentStatuses);
    }

    return newStatuses;
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}
