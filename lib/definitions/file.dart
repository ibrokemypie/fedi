import 'package:json_annotation/json_annotation.dart';
part 'file.g.dart';

@JsonSerializable()
class File {
  String id;
  String date;
  String name;
  String type;
  String authorId;
  bool sensitive;
  String thumbnailUrl;
  String fileUrl;

  File(id, date, name, type, authorId, sensitive, thumbnailUrl,fileUrl) {
    this.id = id;
    this.date = date;
    this.name = name;
    this.type = type;
    this.authorId = authorId;
    this.sensitive = sensitive;
    this.thumbnailUrl = thumbnailUrl;
    this.fileUrl = fileUrl;
  }

  File.fromJson(Map json) {
    this.id = json['id'];
    this.date = json['date'];
    this.name = json['name'];
    this.type = json['type'];
    this.authorId = json['authorId'];
    this.sensitive = json['sensitive'];
    this.thumbnailUrl = json['thumbnailUrl'];
    this.fileUrl = json['fileUrl'];
  }

  Map<String, dynamic> toJson() => _$FileToJson(this);
}
