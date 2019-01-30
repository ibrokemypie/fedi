import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fedi/definitions/item.dart';

getHomeTimeline(Instance instance, String authCode,
    {List<Item> currentStatuses, String sinceId}) async {
  List<Item> statuses;

  switch (instance.type) {
    case "misskey":
      {
        statuses = await getMisskeyHomeTimeline(instance, authCode,
            currentStatuses: currentStatuses, sinceId: sinceId);
        break;
      }
    // TODO: get hometimeline on mastodon
    default:
      {
        throw Exception(instance.type + " isnt supported lol");
      }
  }
  return statuses;
}

Future<List> getMisskeyHomeTimeline(Instance instance, String authCode,
    {List<Item> currentStatuses, String sinceId}) async {
  List<Item> newStatuses = new List();
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
