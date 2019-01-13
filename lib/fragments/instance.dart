import 'package:json_annotation/json_annotation.dart';

part 'instance.g.dart';

@JsonSerializable()
class Instance {
  String type;
  String uri;
  String title;
  String description;
  String version;

  Instance(this.uri, this.title, this.description, this.version, [this.type]) {
    if (this.type == null) {
      if (this.version.contains("misskey")) {
        this.type = "misskey";
      } else if (this.version.contains("pleroma")) {
        this.type = "mastodon";
      } else {
        this.type = "mastodon";
      }
    }
  }

  factory Instance.fromJson(Map<String, dynamic> json) =>
      _$InstanceFromJson(json);

  Map<String, dynamic> toJson() => _$InstanceToJson(this);
}
