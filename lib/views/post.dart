import 'package:flutter/material.dart';
import 'package:fedi/definitions/newpost.dart';
import 'package:fedi/definitions/status.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/api/submitpost.dart';

class Post extends StatefulWidget {
  final Instance instance;
  final String authCode;
  final String preFill;
  final String replyTo;

  Post({this.instance, this.authCode, this.preFill, this.replyTo});
  @override
  PostState createState() => new PostState();
}

class PostState extends State<Post> {
  var submitAction;
  int maxLines = 10;
  int chars = 0;
  String visibility = "public";
  Widget contentWarningField;
  bool hasCw;
  String contentWarning;
  String replyTo;
  TextEditingController textController;

  textUpdated(String currentText) {
    int currentLines = 1 + '\n'.allMatches(currentText).length;
    setState(() {
      maxLines = currentLines + 10;
      chars = currentText.length;
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

  _setVisibility(String newVisibility) {
    setState(() {
      visibility = newVisibility;
    });
  }

  void newPost() async {
    setState(() {
      submitAction = null;
    });
    try {
      NewPost post = NewPost(visibility,
          content: textController.text,
          contentWarning: contentWarning,
          replyTo: replyTo);
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
    replyTo = widget.replyTo;
    textController = TextEditingController(text: widget.preFill ?? "");
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
                      autofocus: true,
                      controller: textController,
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
                  child: PopupMenuButton<String>(
                    child: Material(
                      elevation: 3,
                      type: MaterialType.button,
                      color: Colors.blue,
                      child: Container(
                        child: Icon(
                          visIcon(visibility),
                          size: 16,
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                      ),
                    ),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: "public",
                            child: Text('Public'),
                          ),
                          const PopupMenuItem<String>(
                            value: "home",
                            child: Text('Home'),
                          ),
                          const PopupMenuItem<String>(
                            value: "followers",
                            child: Text('Followers only'),
                          ),
                          const PopupMenuItem<String>(
                            value: "specified",
                            child: Text('Direct'),
                          ),
                        ],
                    onSelected: _setVisibility,
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
