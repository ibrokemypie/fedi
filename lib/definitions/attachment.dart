import 'package:json_annotation/json_annotation.dart';
part 'attachment.g.dart';

@JsonSerializable()
class Attachment {
  String id;
  String date;
  String name;
  String type;
  String authorId;
  bool sensitive;
  String thumbnailUrl;
  String fileUrl;

  Attachment(id, date, name, type, authorId, sensitive, thumbnailUrl, fileUrl) {
    this.id = id;
    this.date = date;
    this.name = name;
    this.type = type;
    this.authorId = authorId;
    this.sensitive = sensitive;
    this.thumbnailUrl = thumbnailUrl;
    this.fileUrl = fileUrl;
  }

  Attachment.fromJson(Map json) {
    this.id = json['id'];
    this.date = json['date'];
    this.name = json['name'];
    this.type = json['type'];
    this.authorId = json['authorId'];
    this.sensitive = json['sensitive'];
    this.thumbnailUrl = json['thumbnailUrl'];
    this.fileUrl = json['fileUrl'];
  }

  Attachment.fromMisskey(Map v) {
    this.id = v["id"];
    this.date = v["createdAt"];
    this.name = v["name"];
    this.type = v["type"];
    this.authorId = v["userId"];
    this.sensitive = v["isSensitive"];
    this.thumbnailUrl = v["thumbnailUrl"];
    this.fileUrl = v["url"];
  }

  Attachment.fromMastodon(Map v, bool sensitive) {
    this.id = v["id"];
    this.type = v["type"];
    this.sensitive = sensitive;
    this.thumbnailUrl = v["preview_url"];
    this.fileUrl = v["url"];
  }

  Map<String, dynamic> toJson() => _$AttachmentToJson(this);
}
