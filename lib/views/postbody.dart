import 'package:html2md/html2md.dart' as html2md;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:flutter/material.dart';
import 'package:fedi/views/webpage.dart';
import 'package:fedi/definitions/instance.dart';

class PostBody extends StatefulWidget {
  final String text;
  final Instance instance;

  PostBody(this.instance, this.text);
  @override
  PostBodyState createState() => new PostBodyState();
}

class PostBodyState extends State<PostBody> {
  String _postText;
  void _linkHandler(String link) {
    if (link.startsWith(new RegExp(r'(https://|ftp://|http://|mailto://)'))) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Webpage(url: link)));
    }
  }

  @override
  void initState() {
    super.initState();
    _postText = html2md.convert(markdown.markdownToHtml(widget.text));
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: _postText,
      onTapLink: _linkHandler,
    );
  }
}
