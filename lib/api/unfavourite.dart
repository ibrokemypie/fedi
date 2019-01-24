import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

unFavouritePost(Instance instance, String authCode, String postId) async {
  bool favourited;

  switch (instance.type) {
    case "misskey":
      {
        favourited = await unFavouriteMisskeyPost(instance, authCode, postId);
        break;
      }
    default:
      {
        throw Exception(instance.type + " isnt supported lol");
      }
  }
  return favourited;
}

Future<bool> unFavouriteMisskeyPost(
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
      return true;
    } else {
      throw Exception('Failed to load post ' +
          (instance.uri + actionPath + json.encode(params)));
    }
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}
