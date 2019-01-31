import 'package:flutter/material.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/definitions/file.dart';
import 'package:photo_view/photo_view.dart';

class StatusFile extends StatefulWidget {
  final File file;

  StatusFile(this.file);
  @override
  StatusFileState createState() => new StatusFileState();
}

class StatusFileState extends State<StatusFile> {
  bool _isVisible;
  File _file;

  @override
  void initState() {
    super.initState();
    setState(() {
      _file = widget.file;

      if (_file.sensitive) {
        _isVisible = false;
      } else {
        _isVisible = true;
      }
    });
  }

  void toggleVisible() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isVisible) {
      return Image.network(
        _file.thumbnailUrl,
        fit: BoxFit.contain,
      );
    } else {
      return InkWell(
          onTap: toggleVisible,
          child: Container(
            width: 200,
            height: 200,
            color: Colors.grey[900],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Marked Sensitive",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Tap to view"),
              ],
            ),
          ));
    }
  }
}

Widget singleFile(Item status, int fileNumber) {
  return Container(child: StatusFile(status.files[fileNumber]));
}

Widget fileRow(Item status, int startAt) {
  return FittedBox(
      child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      StatusFile(status.files[startAt]),
      StatusFile(status.files[startAt + 1]),
    ],
  ));
}

Widget statusFiles(bool isContext, Function moreButtonAction, Item status) {
  switch (status.files.length) {
    case 0:
      return null;
    case 1:
      return singleFile(status, 0);
    case 2:
      return fileRow(status, 0);
    case 3:
      return Column(children: <Widget>[
        fileRow(status, 0),
        singleFile(status, 2),
      ]);
    case 4:
      return Column(children: <Widget>[
        fileRow(status, 0),
        fileRow(status, 2),
      ]);
    default:
      List<Widget> manyItems = [];

      manyItems.addAll([
        fileRow(status, 0),
        fileRow(status, 2),
      ]);

      if (!isContext) {
        manyItems.add(Container(
          // width: double.infinity,
          child: FlatButton(
            color: Colors.grey,
            onPressed: moreButtonAction,
            child: Center(child: Text("More")),
          ),
        ));
      } else {
        if (status.files.length > 4) {
          int remaining = status.files.length - 4;
          int currentNumber = 4;
          while (remaining > 0) {
            if (remaining % 2 == 0) {
              remaining -= 2;
              manyItems.add(fileRow(status, currentNumber));
              currentNumber += 2;
            } else {
              remaining -= 1;
              manyItems.add(singleFile(status, currentNumber));
              currentNumber += 1;
            }
          }
        }
      }

      return Column(children: manyItems);
  }
}
