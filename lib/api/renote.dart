import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

renotePost(Instance instance, String authCode, String postId) async {
  bool renoted;

  switch (instance.type) {
    case "misskey":
      {
        renoted = await renoteMisskeyPost(instance, authCode, postId);
        break;
      }
    // TODO: renote on mastodon
    default:
      {
        throw Exception(instance.type + " isnt supported lol");
      }
  }
  return renoted;
}

Future<bool> renoteMisskeyPost(
    Instance instance, String authCode, String postId) async {
  Map<String, dynamic> params;
  String actionPath = "/api/notes/create";

  params = Map.from({"i": authCode, "renoteId": postId});

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}
