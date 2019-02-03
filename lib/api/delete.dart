import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

Future<void> deletePost(
    Instance instance, String authCode, String postId) async {
  switch (instance.type) {
    case "misskey":
      {
        await deleteMisskeyPost(instance, authCode, postId);
        break;
      }
    default:
      {
        await deleteMastodonPost(instance, authCode, postId);
        break;
      }
  }
}

Future<void> deleteMisskeyPost(
    Instance instance, String authCode, String postId) async {
  Map<String, dynamic> params;
  String actionPath = "/api/notes/delete";

  params = Map.from({"i": authCode, "noteId": postId});

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));

  if (response.statusCode == 200 || response.statusCode ==  204) {
  } else {
    throw Exception(response.body);
  }
}

Future<void> deleteMastodonPost(
    Instance instance, String authCode, String postId) async {
  String actionPath = "/api/v1/statuses/" + postId;

  final response = await http.delete(instance.uri + actionPath,
      headers: {"Authorization": "bearer " + authCode});

  if (response.statusCode == 200) {
  } else {
    throw Exception(response.body);
  }
}
