import 'package:flutter/material.dart';
import 'package:fedi/definitions/newpost.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/api/submitpost.dart';

class Post extends StatefulWidget {
  final Instance instance;
  final String authCode;

  Post({this.instance, this.authCode});
  @override
  PostState createState() => new PostState();
}

class PostState extends State<Post> {
  var submitAction;
  int maxLines = 10;
  int chars = 0;
  String currentContent;
  String visibility = "public";
  Widget contentWarningField;
  bool hasCw;
  String contentWarning;

  textUpdated(String currentText) {
    int currentLines = 1 + '\n'.allMatches(currentText).length;
    setState(() {
      maxLines = currentLines + 10;
      chars = currentText.length;
      currentContent = currentText;
    });
  }

  _contentWarningUpdated(String currentCw) {
    setState(() {
      contentWarning = currentCw;
    });
  }

  _toggleContentWarning() {
    if (hasCw != true) {
      setState(() {
        hasCw = true;
        contentWarningField = new Container(
            child: FormField(
          builder: (FormFieldState<int> state) => TextField(
                onChanged: _contentWarningUpdated,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(16),
                    hintText: "Content Warning"),
              ),
        ));
      });
    } else {
      setState(() {
        hasCw = false;
        contentWarning = null;
        contentWarningField = new Container();
      });
    }
  }

  void newPost() async {
    setState(() {
      submitAction = null;
    });
    try {
      NewPost post = NewPost(visibility, content: currentContent, contentWarning: contentWarning);
      var createdNote =
          await submitPost(widget.instance, widget.authCode, post);
      Navigator.pop(context);
    } catch (e) {
      submitAction = newPost;
    }
  }

  @override
  void initState() {
    super.initState();
    submitAction = newPost;
    contentWarningField = new Container();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(children: <Widget>[
        contentWarningField,
        SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: FormField(
                builder: (FormFieldState<int> state) => TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: maxLines,
                      onChanged: textUpdated,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Write away!'),
                    )))
      ]),
      bottomNavigationBar: BottomAppBar(
          color: Colors.red,
          child: Container(
              child: Row(
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.only(left: 16, right: 4),
                  child: RaisedButton(
                    child: Icon(
                      Icons.image,
                      size: 16,
                    ),
                    onPressed: () => {},
                  )),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: RaisedButton(
                    child: Icon(
                      Icons.public,
                      size: 16,
                    ),
                    onPressed: () => {},
                  )),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: RaisedButton(
                    child: Text(
                      "CW",
                      style: TextStyle(fontSize: 10),
                    ),
                    onPressed: _toggleContentWarning,
                  )),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: RaisedButton(
                    child: Icon(
                      Icons.face,
                      size: 16,
                    ),
                    onPressed: () => {},
                  )),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(chars.toString() + "/2000")),
              Spacer(),
              Container(
                padding: const EdgeInsets.only(right: 16),
                child: RaisedButton(
                  child: Text("Submit"),
                  onPressed: submitAction,
                ),
              )
            ],
          ))),
    ));
  }
}
