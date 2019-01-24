import 'package:json_annotation/json_annotation.dart';
part 'newpost.g.dart';

@JsonSerializable()
class NewPost {
  String content;
  String contentWarning;
  String replyTo;
  String visiblity;

  NewPost(visiblity, {content, contentWarning, replyTo}) {
    this.visiblity = visiblity;
    this.content = content;
    this.contentWarning = contentWarning;
    this.replyTo = replyTo;
  }

    Map<String, dynamic> toJson() => _$NewPostToJson(this);
}
