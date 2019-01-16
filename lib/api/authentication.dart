import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fedi/definitions/shared.dart';

instanceLogin(String instanceUrl) async {
  Instance instance = await Instance.fromUrl(instanceUrl);
  switch (instance.type) {
    case "misskey":
      {
        await misskeyAuth(instance);
        break;
      }
    default:
      {
        throw Exception(instance.type + " isnt supported lol");
      }
  }
}

misskeyAuth(Instance instance) async {
  // First register the app and get appId and appSecret
  Map<String, dynamic> appAuth = await misskeyAppRegister(instance);
  String appId = appAuth["id"];
  String appSecret = appAuth["secret"];

  // The generate a session to get the app token and the url to show the user
  Map<String, dynamic> appSession =
      await misskeySessionGenerate(instance, appId, appSecret);
  String sessionToken = appSession["token"];
  String sessionUrl = appSession["url"];

  print(sessionToken);
  print(sessionUrl);
}

misskeyAppRegister(Instance instance) async {
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

misskeySessionGenerate(
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
