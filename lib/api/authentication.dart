import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';
import 'dart:async';
import 'package:fedi/definitions/shared.dart';
import 'package:flutter/material.dart';
import 'package:fedi/views/webauth.dart';
import 'package:crypto/crypto.dart';

Future<String> instanceLogin(BuildContext context, String instanceUrl) async {
  Instance instance = await Instance.fromUrl(instanceUrl);
  String userAuth;
  switch (instance.type) {
    case "misskey":
      {
        userAuth = await misskeyAuth(context, instance);
        break;
      }
    // TODO: authenticate mastodon
    default:
      {
        userAuth = await mastodonAuth(context, instance);
        break;
      }
  }
  return userAuth;
}

Future<String> misskeyAuth(BuildContext context, Instance instance) async {
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

  String accessToken = (await misskeyAccessTokenGenerate(
      instance, appSecret, sessionToken))["accessToken"];

  var userAuth = await misskeyIGenerate(instance, accessToken, appSecret);

  return userAuth;
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

Future<Map<String, dynamic>> misskeyAccessTokenGenerate(
    Instance instance, String appSecret, String sessionToken) async {
  String actionPath = "/api/auth/session/userkey";
  Map<String, dynamic> params = Map.from({
    "appSecret": appSecret,
    "token": sessionToken,
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

Future<String> misskeyIGenerate(
    Instance instance, String accessToken, String appSecret) async {
  List<int> bytes = utf8.encode(accessToken + appSecret);
  String userI = sha256.convert(bytes).toString();

  String actionPath = "/api/i";
  Map<String, dynamic> params = Map.from({
    "i": userI,
  });

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));

  if (response.statusCode == 200) {
    Map<String, dynamic> returned = json.decode(response.body);
    if (returned["username"] != null) {
      return userI;
    } else {
      throw Exception('user code invalid');
    }
  } else {
    throw Exception('Failed to load post');
  }
}

Future<String> mastodonAuth(BuildContext context, Instance instance) async {
  // First register the app and get appId and appSecret
  var appAuth = await mastodonAppRegister(instance);
  String appId = appAuth["client_id"];
  String appSecret = appAuth["client_secret"];

  String authCode = await mastodonAuthSession(context, instance, appId);

  String accessToken =
      await mastodonAccessToken(instance, appId, appSecret, authCode);

  return accessToken;
}

Future<Map<String, dynamic>> mastodonAppRegister(Instance instance) async {
  String actionPath = "/api/v1/apps";
  Map<String, String> params = Map.from({
    "client_name": appName,
    "redirect_uris": appCallbackUri,
    "website": appHomepage,
    "scopes": mastodonScope
  });

  final response = await http.post(instance.uri + actionPath, body: params);

  if (response.statusCode == 200) {
    Map<String, dynamic> returned = json.decode(response.body);
    return returned;
  } else {
    throw Exception('Failed to load post');
  }
}

Future<String> mastodonAuthSession(
    BuildContext context, Instance instance, String appId) async {
  String actionPath = "/oauth/authorize";
  Map<String, String> params = Map.from({
    "scope": mastodonScope,
    "response_type": "code",
    "redirect_uri": appCallbackUri,
    "client_id": appId
  });

  String dest = instance.uri + actionPath + "?" + uriEncodeMap(params);

  String authUrl = await Navigator.push(
      context, MaterialPageRoute(builder: (context) => WebAuth(url: dest)));
  if (authUrl.startsWith("fedi://appredirect")) {
    Uri returnedUri = Uri.parse(authUrl);
    String authCode = returnedUri.queryParameters["code"];
    print("authenticated " + authCode);
    return authCode;
  } else {
    throw Exception(authUrl);
  }
}

Future<String> mastodonAccessToken(
    Instance instance, String appId, String appSecret, String authCode) async {
  String actionPath = "/oauth/token";
  Map<String, String> params = Map.from({
    "client_id": appId,
    "client_secret": appSecret,
    "grant_type": "authorization_code",
    "redirect_uri": appCallbackUri,
    "code": authCode,
  });

  final response = await http.post(instance.uri + actionPath, body: params);

  if (response.statusCode == 200) {
    Map<String, dynamic> returned = json.decode(response.body);
    return returned["access_token"];
  } else {
    throw Exception('Failed to load post');
  }
}
