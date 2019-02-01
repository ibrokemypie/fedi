import 'package:json_annotation/json_annotation.dart';
import 'package:fedi/definitions/attachment.dart';
part 'newpost.g.dart';

@JsonSerializable()
class NewPost {
  String content;
  String contentWarning;
  String replyTo;
  String visiblity;
  List<Attachment> attachments;

  NewPost(visiblity, {content, contentWarning, replyTo,attachments}) {
    this.visiblity = visiblity;
    this.content = content;
    this.contentWarning = contentWarning;
    this.replyTo = replyTo;
    this.attachments = attachments;
  }

    Map<String, dynamic> toJson() => _$NewPostToJson(this);
}
