import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fedi/definitions/user.dart';

Future<User> getUserFromId(Instance instance, String userId) async {
  User foundUser;

  switch (instance.type) {
    case "misskey":
      {
        foundUser = await getUserFromIdMisskey(instance, userId);
        break;
      }
    case "mastodon":
      {
        foundUser = await getUserFromIdMastodon(instance, userId);
        break;
      }
    default:
      {
        throw (instance.type + " not supported");
      }
  }
  return foundUser;
}

Future<User> getUserFromIdMisskey(Instance instance, String userId) async {
  Map<String, dynamic> params;
  String actionPath = "/api/users/show";

  params = Map.from({
    "userId": userId,
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

Future<User> getUserFromIdMastodon(Instance instance, String userId) async {
  Map<String, dynamic> params;
  String actionPath = "/api/v1/accounts/" + userId;

  final response = await http.get(instance.uri + actionPath);

  if (response.statusCode == 200) {
    var returned = json.decode(response.body);
    return User.fromMastodon(returned, instance);
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}

Future<User> getUserFromUsername(
    Instance instance, String username, String host) async {
  User foundUser;

  switch (instance.type) {
    case "misskey":
      {
        foundUser = await getUserFromUsernameMisskey(instance, username, host);
        break;
      }
    default:
      {
        throw (instance.type + " not supported");
      }
  }
  return foundUser;
}

Future<User> getUserFromUsernameMisskey(
    Instance instance, String username, String host) async {
  Map<String, dynamic> params;
  String actionPath = "/api/users/show";

  params = Map.from({
    "username": username,
    "host": host,
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
