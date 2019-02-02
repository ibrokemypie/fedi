import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

Future<void> renotePost(
    Instance instance, String authCode, String postId) async {
  switch (instance.type) {
    case "misskey":
      {
        await renoteMisskeyPost(instance, authCode, postId);
        break;
      }
    default:
      {
        await renoteMastodonPost(instance, authCode, postId);
        break;
      }
  }
}

Future<void> renoteMisskeyPost(
    Instance instance, String authCode, String postId) async {
  Map<String, dynamic> params;
  String actionPath = "/api/notes/create";

  params = Map.from({"i": authCode, "renoteId": postId});

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));

  if (response.statusCode == 200) {
  } else {
    throw Exception(response.body);
  }
}

Future<void> renoteMastodonPost(
    Instance instance, String authCode, String postId) async {
  String actionPath = "/api/v1/statuses/" + postId + "/reblog";

  final response = await http.post(instance.uri + actionPath,
      headers: {"Authorization": "bearer " + authCode});

  if (response.statusCode == 200) {
  } else {
    throw Exception(response.body);
  }
}
