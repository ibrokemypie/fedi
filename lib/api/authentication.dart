import 'package:fedi/fragments/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fedi/fragments/shared.dart';

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
    String appId = returned["id"];
    String appSecret = returned["secret"];
    print(appId);
    print(appSecret);
  } else {
    throw Exception('Failed to load post');
  }
}
