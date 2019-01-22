import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fedi/definitions/shared.dart';
import 'package:flutter/material.dart';
import 'package:fedi/views/webauth.dart';
import 'package:fedi/views/timeline.dart';

Future<void> instanceLogin(BuildContext context, String instanceUrl) async {
  Instance instance = await Instance.fromUrl(instanceUrl);
  switch (instance.type) {
    case "misskey":
      {
        await misskeyAuth(context, instance);
        break;
      }
    default:
      {
        throw Exception(instance.type + " isnt supported lol");
      }
  }
}

Future<void> misskeyAuth(BuildContext context, Instance instance) async {
  // First register the app and get appId and appSecret
  Map<String, dynamic> appAuth = await misskeyAppRegister(instance);
  String appId = appAuth["id"];
  String appSecret = appAuth["secret"];

  // The generate a session to get the app token and the url to show the user
  Map<String, dynamic> appSession =
      await misskeySessionGenerate(instance, appId, appSecret);
  String sessionToken = appSession["token"];
  String sessionUrl = appSession["url"];

  await misskeyAuthSession(context, sessionUrl, sessionToken);

  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => TimeLine()));
}

Future<Map<String, dynamic>> misskeyAppRegister(Instance instance) async {
  String actionPath = "/api/app/create";
  Map<String, dynamic> params = Map.from({
    "name": appName,
    "description": appDescription,
    "callbackUrl": appCallbackUri,
    "website": appHomepage,
    "permission": misskeyScope
  });

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));

  if (response.statusCode == 200) {
    Map<String, dynamic> returned = json.decode(response.body);
    return returned;
  } else {
    throw Exception('Failed to load post');
  }
}

Future<Map<String, dynamic>> misskeySessionGenerate(
    Instance instance, String appId, String appSecret) async {
  String actionPath = "/api/auth/session/generate";
  Map<String, dynamic> params = Map.from({
    "appSecret": appSecret,
  });

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));

  if (response.statusCode == 200) {
    Map<String, dynamic> returned = json.decode(response.body);
    return returned;
  } else {
    throw Exception('Failed to load post');
  }
}

Future<void> misskeyAuthSession(
    BuildContext context, String sessionUrl, String sessionToken) async {
  String authUrl = await Navigator.push(context,
      MaterialPageRoute(builder: (context) => WebAuth(url: sessionUrl)));
  if (authUrl.startsWith("fedi://appredirect")) {
    print("authenticated " + sessionToken);
  } else {
    throw Exception(authUrl);
  }
}
