import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fedi/definitions/user.dart';

Future<void> unFollowUser(
    Instance instance, String authCode, String userId) async {
  switch (instance.type) {
    case "misskey":
      {
        await unFollowMisskeyUser(instance, authCode, userId);
        break;
      }
    case "mastodon":
      {
        await unFollowMastodonUser(instance, authCode, userId);
        break;
      }
    default:
      {
        throw (instance.type + "not supported");
      }
  }
}

Future<void> unFollowMisskeyUser(
    Instance instance, String authCode, String userId) async {
  Map<String, dynamic> params;
  String actionPath = "/api/following/delete";

  params = Map.from({
    "i": authCode,
    "userId": userId,
  });

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));

  if (response.statusCode == 200) {
    print(response);
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}

Future<void> unFollowMastodonUser(
    Instance instance, String authCode, String userId) async {
  Map<String, dynamic> params;
  String actionPath = "/api/v1/accounts" + userId + "/unfollow";

  final response = await http.post(instance.uri + actionPath,
      body: params, headers: {"Authorization": "bearer " + authCode});

  if (response.statusCode == 200) {
    print(response);
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}
