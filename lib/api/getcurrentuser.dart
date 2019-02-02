import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fedi/definitions/user.dart';

Future<User> getCurrentUser(Instance instance, String authCode) async {
  User foundUser;

  switch (instance.type) {
    case "misskey":
      {
        foundUser = await getCurrentUserMisskey(instance, authCode);
        break;
      }
    case "mastodon":
      {
        foundUser = await getCurrentUserMastodon(instance, authCode);
        break;
      }
    default:
      {
        throw (instance.type + " not supported");
      }
  }
  return foundUser;
}

Future<User> getCurrentUserMisskey(Instance instance, String authCode) async {
  Map<String, dynamic> params;
  String actionPath = "/api/i";

  params = Map.from({
    "i": authCode,
  });

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));

  if (response.statusCode == 200) {
    var returned = json.decode(response.body);
    return User.fromMisskey(returned, instance);
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}

Future<User> getCurrentUserMastodon(Instance instance, String authCode) async {
  Map<String, dynamic> params;
  String actionPath = "/api/v1/accounts/verify_credentials";

  final response = await http.get(instance.uri + actionPath,
      headers: {"Authorization": "Bearer " + authCode});

  if (response.statusCode == 200) {
    var returned = json.decode(response.body);
    return User.fromMastodon(returned, instance);
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}
