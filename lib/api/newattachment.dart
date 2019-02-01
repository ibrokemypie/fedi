import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:fedi/definitions/attachment.dart';

Future<Attachment> newAttachment(Instance instance, String authCode,
    File attachment, bool isSensitive) async {
  Attachment createdAttachment;

  switch (instance.type) {
    case "misskey":
      {
        createdAttachment = await newMisskeyAttachment(
            instance, authCode, attachment, isSensitive);
        break;
      }
    default:
      {
        createdAttachment = await newMastodonAttachment(
            instance, authCode, attachment, isSensitive);
        break;
      }
  }
  return createdAttachment;
}

Future<Attachment> newMisskeyAttachment(Instance instance, String authCode,
    File attachment, bool isSensitive) async {
  Map<String, dynamic> params;
  String actionPath = "/api/drive/files/create";

  var request =
      http.MultipartRequest("POST", Uri.parse(instance.uri + actionPath));

  request.fields['i'] = authCode;
  request.fields['isSensitive'] = isSensitive.toString();

  request.files.add(new http.MultipartFile.fromBytes(
      "file", attachment.readAsBytesSync(),
      filename: basename(attachment.path)));

  Map returned;

  final response = await request.send();
  if (response.statusCode == 200) {
    var decoder = new Utf8Decoder(allowMalformed: true);
    await response.stream
        .transform(decoder)
        .listen((data) => returned = json.decode(data));

    Attachment newA = Attachment.fromMisskey(returned);
    print(newA.toJson());
    return newA;
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}

Future<Attachment> newMastodonAttachment(Instance instance, String authCode,
    File attachment, bool isSensitive) async {
  // Map<String, dynamic> params;
  // String actionPath = "/api/v1/statuses";

  // params = Map.from({
  //   "status": post.content,
  //   "visibility": post.visiblity,
  // });

  // if (post.replyTo != null)
  //   params.putIfAbsent("in_reply_to_id", () => post.replyTo);

  // if (post.contentWarning != null)
  //   params.putIfAbsent("spoiler_text", () => post.contentWarning);

  // final response = await http.post(instance.uri + actionPath,
  //     body: params, headers: {"Authorization": "bearer " + authCode});

  // if (response.statusCode == 200) {
  //   var returned = json.decode(response.body);
  //   return returned;
  // } else {
  //   throw Exception('Failed to load post ' +
  //       (instance.uri + actionPath + json.encode(params)));
  // }
}
