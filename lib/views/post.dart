import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  @override
  PostState createState() => new PostState();
}

class PostState extends State<Post> {
  int maxLines = 10;
  int chars = 0;

  textUpdated(String currentText) {
    int currentLines = 1 + '\n'.allMatches(currentText).length;
    setState(() {
      maxLines = currentLines + 10;
      chars = currentText.length;
    });
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
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FormField(
              builder: (FormFieldState<int> state) => TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: maxLines,
                    onChanged: textUpdated,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Write away!'),
                  ))),
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
                    onPressed: () => {},
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
                  onPressed: () => {},
                ),
              )
            ],
          ))),
    ));
  }
}
