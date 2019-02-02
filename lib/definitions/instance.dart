import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

part 'instance.g.dart';

@JsonSerializable()
class Instance {
  String type;
  String uri;
  String title;
  String description;
  String version;
  String protocol;
  String host;
  int maxChars;

  Instance(this.uri, this.protocol, this.host, this.title, this.description,
      this.version,
      [this.type]) {
    String version = this.version.toLowerCase();
    if (this.type == null) {
      if (version.contains("misskey")) {
        this.type = "misskey";

        // TODO: change things for pleroma
      } else if (version.contains("pleroma")) {
        this.type = "mastodon";
      } else {
        this.type = "mastodon";
      }
    }
  }

  static Future<Instance> fromUrl(String instanceUrl) async {
    try {
      String protocol;
      if (instanceUrl.startsWith('http://')) {
        protocol = "http://";
      } else {
        protocol = "https://";
      }

      Uri instanceUri = Uri.parse(protocol + instanceUrl);

      try {
        final response = await http.post(instanceUri.toString() + "/api/meta");

        if (response.statusCode == 200) {
          Map<String, dynamic> returned = json.decode(response.body);
          returned.addAll({
            "protocol": Uri.parse(returned["uri"]).scheme,
            "host": Uri.parse(returned["uri"]).host,
            "maxChars": returned["maxNoteTextLength"] ?? 500,
            "type": "misskey",
          });
          // If server returns an OK response, parse the JSON
          return Instance.fromJson(returned);
        } else {
          throw Exception(response.body);
        }
      } catch (e) {
        try {
          final response =
              await http.get(instanceUri.toString() + "/api/v1/instance");

          if (response.statusCode == 200) {
            Map<String, dynamic> returned = json.decode(response.body);
            returned.addAll({
              "protocol": instanceUri.scheme,
              "uri": instanceUri.toString(),
              "host": instanceUri.host,
              "maxChars": returned["max_toot_chars"] ??
                  returned["maxNoteTextLength"] ??
                  500,
            });
            // If server returns an OK response, parse the JSON
            return Instance.fromJson(returned);
          } else {
            throw Exception(response.body);
          }
        } catch (e) {
          throw e;
        }
      }
    } catch (exception) {
      throw exception;
    }
  }

  factory Instance.fromJson(Map<String, dynamic> json) =>
      _$InstanceFromJson(json);

  Map<String, dynamic> toJson() => _$InstanceToJson(this);
}
