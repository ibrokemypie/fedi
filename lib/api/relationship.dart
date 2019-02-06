import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fedi/definitions/relationship.dart';

Future<Relationship> getRelationship(
    Instance instance, String authCode, String userId) async {
  Relationship relationship;

  switch (instance.type) {
    case "misskey":
      {
        relationship = await getMisskeyRelationship(instance, authCode, userId);
        break;
      }
    case "mastodon":
      {
        relationship =
            await getMastodonRelationship(instance, authCode, userId);
        break;
      }
    default:
      {
        throw (instance.type + "not supported");
      }
  }
  return relationship;
}

Future<Relationship> getMisskeyRelationship(
    Instance instance, String authCode, String userId) async {
  Map<String, dynamic> params;
  String actionPath = "/api/users/relation";

  params = Map.from({
    "i": authCode,
    "userId": userId,
  });

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));

  if (response.statusCode == 200) {
    Map<String, dynamic> returned = json.decode(response.body);

    return Relationship.fromMisskey(returned);
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}

Future<Relationship> getMastodonRelationship(
    Instance instance, String authCode, String userId) async {
  String actionPath = "/api/v1/accounts/relationships";

  String paramString = "?id=" + userId;

  final response = await http.get(instance.uri + actionPath + paramString,
      headers: {"Authorization": "bearer " + authCode});

  if (response.statusCode == 200) {
    Map<String, dynamic> returned = json.decode(response.body)[0];

    return Relationship.fromMastodon(returned);
  } else {
    throw Exception(
        'Failed to load post ' + (instance.uri + actionPath + paramString));
  }
}
