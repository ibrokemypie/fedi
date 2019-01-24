import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fedi/definitions/newpost.dart';

submitPost(Instance instance, String authCode, NewPost post) async {
  var createdNote;

  switch (instance.type) {
    case "misskey":
      {
        createdNote = await getMisskeyHomeTimeline(instance, authCode, post);
        break;
      }
    default:
      {
        throw Exception(instance.type + " isnt supported lol");
      }
  }
  return createdNote;
}

Future<dynamic> getMisskeyHomeTimeline(
    Instance instance, String authCode, NewPost post) async {
  Map<String, dynamic> params;
  String actionPath = "/api/notes/create";

  params = Map.from(
      {"i": authCode, "text": post.content, "visibility": post.visiblity});

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));


  if (response.statusCode == 200) {
    var returned = json.decode(response.body);
    return returned;
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}
