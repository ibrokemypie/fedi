import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

Future<void> unFavouritePost(
    Instance instance, String authCode, String postId) async {
  switch (instance.type) {
    case "misskey":
      {
        await unFavouriteMisskeyPost(instance, authCode, postId);
        break;
      }
    default:
      {
        await unFavouriteMastodonPost(instance, authCode, postId);
        break;
      }
  }
}

Future<void> unFavouriteMisskeyPost(
    Instance instance, String authCode, String postId) async {
  Map<String, dynamic> params;
  String actionPath = "/api/notes/favorites/delete";

  params = Map.from({"i": authCode, "noteId": postId});

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));

  if (response.statusCode == 204) {
    String actionPath = "/api/notes/reactions/delete";
    params = Map.from({"i": authCode, "noteId": postId});
    final response =
        await http.post(instance.uri + actionPath, body: json.encode(params));
    if (response.statusCode == 204) {
    } else {
      throw Exception(response.body);
    }
  } else {
    throw Exception(response.body);
  }
}

Future<void> unFavouriteMastodonPost(
    Instance instance, String authCode, String postId) async {
  String actionPath = "/api/v1/statuses/" + postId + "/unfavourite";

  final response = await http.post(instance.uri + actionPath,
      headers: {"Authorization": "bearer " + authCode});

  if (response.statusCode == 200) {
  } else {
    throw Exception(response.body);
  }
}
