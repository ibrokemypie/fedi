import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:flutter/material.dart';
import 'package:fedi/views/webpage.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/definitions/item.dart';

class PostBody extends StatefulWidget {
  final Item status;
  final Instance instance;

  PostBody(this.instance, this.status);
  @override
  PostBodyState createState() => new PostBodyState();
}

class PostBodyState extends State<PostBody> {
  String _postText;

  @override
  void initState() {
    super.initState();

    if (widget.instance.type == "misskey") {
      _postText = markdown.markdownToHtml(widget.status.body);
    } else {
      _postText = widget.status.body;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Html(
      data: _postText,
      blockSpacing: 0,
      onLinkTap: (String link) {
        if (link
            .startsWith(new RegExp(r'(https://|ftp://|http://|mailto://)'))) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Webpage(url: link)));
        }
      },
    );
  }
}
