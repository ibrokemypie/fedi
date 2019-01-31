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
        createdNote = await submitMisskeyPost(instance, authCode, post);
        break;
      }
    default:
      {
        createdNote = await submitMastodonPost(instance, authCode, post);
        break;
      }
  }
  return createdNote;
}

Future<dynamic> submitMisskeyPost(
    Instance instance, String authCode, NewPost post) async {
  Map<String, dynamic> params;
  String actionPath = "/api/notes/create";

  params = Map.from({
    "i": authCode,
    "text": post.content,
    "visibility": post.visiblity,
    "viaMobile": true,
  });

  if (post.replyTo != null)
    params.putIfAbsent("replyId", () => post.replyTo);

  if (post.contentWarning != null)
    params.putIfAbsent("cw", () => post.contentWarning);

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


Future<dynamic> submitMastodonPost(
    Instance instance, String authCode, NewPost post) async {
  Map<String, dynamic> params;
  String actionPath = "/api/v1/statuses";

  params = Map.from({
    "status": post.content,
    "visibility": post.visiblity,
  });

  if (post.replyTo != null)
    params.putIfAbsent("in_reply_to_id", () => post.replyTo);

  if (post.contentWarning != null)
    params.putIfAbsent("spoiler_text", () => post.contentWarning);

  final response =
      await http.post(instance.uri + actionPath, body: params,
      headers: {"Authorization": "bearer " + authCode});

  if (response.statusCode == 200) {
    var returned = json.decode(response.body);
    return returned;
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}
