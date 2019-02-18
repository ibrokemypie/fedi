import 'package:flutter/material.dart';
import 'package:fedi/definitions/newpost.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/definitions/attachment.dart';
import 'package:fedi/api/submitpost.dart';
import 'package:fedi/api/newattachment.dart';
import 'package:fedi/views/visiblewhenfocused.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

class Post extends StatefulWidget {
  final Instance instance;
  final String authCode;
  final String preFillBody;
  final String preFillContentWarning;
  final String visibility;
  final String replyTo;

  Post(
      {this.instance,
      this.authCode,
      this.preFillBody,
      this.preFillContentWarning,
      this.replyTo,
      this.visibility});
  @override
  PostState createState() => new PostState();
}

class PostState extends State<Post> with WidgetsBindingObserver {
  var submitAction;
  int maxLines = 10;
  int chars = 0;
  String visibility;
  Widget contentWarningField;
  Widget mediaRow;
  bool hasCw;
  String contentWarning;
  String replyTo;
  TextEditingController bodyTextController;
  TextEditingController cwTextController;
  List<Attachment> _attachmentList = new List();
  List<File> _mediaList = new List();
  bool _posted = false;
  FocusNode _focusNode = new FocusNode();
  double _bottomHeight = 48.0;

  textUpdated(String currentText) {
    int currentLines = 1 + '\n'.allMatches(currentText).length;
    setState(() {
      maxLines = currentLines + 1;
      chars = currentText.length;
    });
  }

  _contentWarningUpdated(String currentCw) {
    setState(() {
      contentWarning = currentCw;
    });
  }

  _toggleContentWarning() {
    if (!_posted) {
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
  }

  _setVisibility(String newVisibility) {
    if (!_posted) {
      setState(() {
        visibility = newVisibility;
      });
    }
  }

  _addMedia() async {
    if (!_posted) {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
        _mediaList.add(image);
      });
      _updateMediaRow();
    }
  }

  _removeMedia(File target) async {
    if (!_posted) {
      setState(() {
        _mediaList.remove(target);
      });
      _updateMediaRow();
    }
  }

  _removeMediaButton(File target) {
    return Transform.translate(
      offset: Offset(60, -3),
      child: Container(
        width: 36,
        height: 36,
        color: Color.fromARGB(150, 42, 42, 42),
        child: IconButton(
          icon: Icon(Icons.delete),
          iconSize: 18,
          color: Colors.grey[200],
          onPressed: () => _removeMedia(target),
        ),
      ),
    );
  }

  _updateMediaRow() {
    if (_mediaList.length == 0) {
      setState(() {
        mediaRow = new Container(
          height: 0,
        );
        _bottomHeight = 48.0;
      });
    } else {
      List<Widget> mediaWidgetList = new List();
      for (File file in _mediaList) {
        mediaWidgetList.add(new Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Stack(children: <Widget>[
              Container(
                  color: Colors.grey,
                  child: Image.file(
                    file,
                    fit: BoxFit.contain,
                    width: 85,
                    height: 85,
                  )),
              _removeMediaButton(file),
            ])));
      }
      mediaRow = new Container(
          height: 95,
          margin: EdgeInsets.only(top: 8.0),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: mediaWidgetList,
          ));
      setState(() {
        _bottomHeight = 151.0;
      });
    }
  }

  Future<void> _uploadAttachments() async {
    for (File file in _mediaList) {
      Attachment attachment =
          await newAttachment(widget.instance, widget.authCode, file, false);
      setState(() {
        _attachmentList.add(attachment);
      });
    }
    return true;
  }

  void newPost() async {
    setState(() {
      submitAction = null;
      _posted = true;
    });
    try {
      if (chars <= widget.instance.maxChars) {
        await _uploadAttachments();
        NewPost post = NewPost(visibility,
            content: bodyTextController.text,
            contentWarning: contentWarning,
            replyTo: replyTo,
            attachments: _attachmentList);
        var createdNote =
            await submitPost(widget.instance, widget.authCode, post);
        Navigator.pop(context, createdNote);
      } else {
        setState(() {
          submitAction = newPost;
          _posted = false;
        });
      }
    } catch (e) {
      submitAction = newPost;
      _posted = false;
    }
  }

  Future<Null> _focusNodeListener() async {
    if (_focusNode.hasFocus) {
      print('TextField got the focus');
    } else {
      print('TextField lost the focus');
    }
  }

  @override
  void initState() {
    super.initState();
    replyTo = widget.replyTo;
    bodyTextController = TextEditingController(text: widget.preFillBody ?? "");
    cwTextController =
        TextEditingController(text: widget.preFillContentWarning ?? "");
    submitAction = newPost;
    visibility = widget.visibility ?? "public";
    _focusNode.addListener(_focusNodeListener);
    WidgetsBinding.instance.addObserver(this);

    if (widget.preFillContentWarning != null) {
      hasCw = true;
      contentWarning = widget.preFillContentWarning;
      contentWarningField = new Container(
          child: FormField(
        builder: (FormFieldState<int> state) => TextField(
              controller: cwTextController,
              onChanged: _contentWarningUpdated,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  hintText: "Content Warning"),
            ),
      ));
    } else {
      contentWarningField = new Container();
    }
    mediaRow = new Container(
      height: 0,
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusNodeListener);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {}

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
            body: Form(
                child: Column(children: <Widget>[
              contentWarningField,
              Expanded(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.all(16),
                      child: FormField(
                          builder: (FormFieldState<int> state) =>
                              new EnsureVisibleWhenFocused(
                                  focusNode: _focusNode,
                                  child: TextField(
                                    autofocus: true,
                                    focusNode: _focusNode,
                                    maxLength: widget.instance.maxChars,
                                    controller: bodyTextController,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    onChanged: textUpdated,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Write away!',
                                      counterText: "",
                                    ),
                                  ))))),
              SizedBox(
                height: _bottomHeight,
              )
            ])),
            bottomNavigationBar: Transform.translate(
                offset:
                    Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
                child: BottomAppBar(
                    color: Colors.red,
                    child: Column(mainAxisSize: MainAxisSize.min, children: <
                        Widget>[
                      mediaRow,
                      ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 50),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                          padding:
                                              const EdgeInsets.only(right: 4),
                                          child: RaisedButton(
                                            child: Icon(
                                              Icons.image,
                                              size: 16,
                                            ),
                                            onPressed: () => _addMedia(),
                                          )),
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 16),
                                              ),
                                            ),
                                            itemBuilder: (BuildContext
                                                    context) =>
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
                                                    child:
                                                        Text('Followers only'),
                                                  ),
                                                  const PopupMenuItem<String>(
                                                    value: "specified",
                                                    child: Text('Direct'),
                                                  ),
                                                ],
                                            onSelected: _setVisibility,
                                          )),
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: RaisedButton(
                                            child: Text(
                                              "CW",
                                              style: TextStyle(fontSize: 10),
                                            ),
                                            onPressed: _toggleContentWarning,
                                          )),
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: RaisedButton(
                                            child: Icon(
                                              Icons.face,
                                              size: 16,
                                            ),
                                            // TODO: emoji selection
                                            onPressed: () => {},
                                          )),
                                    ],
                                  ),
                                ),
                              )),
                              Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(chars.toString() +
                                      "/" +
                                      widget.instance.maxChars.toString())),
                              // Spacer(),
                              Container(
                                padding: const EdgeInsets.only(right: 16),
                                child: RaisedButton(
                                  child: Text("Submit"),
                                  onPressed: submitAction,
                                ),
                              )
                            ],
                          ))
                    ])))));
  }
}
