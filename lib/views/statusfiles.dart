import 'package:flutter/material.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/definitions/file.dart';
import 'package:fedi/views/imageviewer.dart';

class StatusFile extends StatefulWidget {
  final List<File> files;
  final int fileNumber;
  final Function showImage;

  StatusFile(this.files, this.fileNumber, this.showImage);
  @override
  StatusFileState createState() => new StatusFileState();
}

class StatusFileState extends State<StatusFile> {
  bool _isVisible;
  List<File> _files;
  File _file;
  Widget _toggleButton = Container();

  @override
  void initState() {
    super.initState();
    setState(() {
      _files = widget.files;
      _file = _files[widget.fileNumber];

      if (_file.sensitive == true) {
        _isVisible = false;
        _toggleButton = Positioned(
          right: 0,
          top: 0,
          child: IconButton(
            icon: Icon(Icons.remove_red_eye),
            color: Colors.grey,
            onPressed: toggleVisible,
          ),
        );
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
      return Stack(
        children: <Widget>[
          FlatButton(
            onPressed: () => widget.showImage(_files, widget.fileNumber),
            child: Image.network(
              _file.thumbnailUrl,
              fit: BoxFit.cover,
              height: 200,
            ),
          ),
          _toggleButton
        ],
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

Widget singleFile(Item status, int fileNumber, Function showImage) {
  return Container(child: StatusFile(status.files, fileNumber, showImage));
}

Widget fileRow(Item status, int startAt, Function showImage) {
  return FittedBox(
      child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      StatusFile(status.files, startAt, showImage),
      StatusFile(status.files, startAt + 1, showImage),
    ],
  ));
}

class statusFiles extends StatelessWidget {
  bool isContext;
  Function moreButtonAction;
  Item status;
  statusFiles(this.isContext, this.moreButtonAction, this.status);

  @override
  Widget build(BuildContext context) {
    void viewImage(List<File> files, int currentFile) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => imageViewer(files, currentFile)));
    }

    switch (status.files.length) {
      case 0:
        return Container();
      case 1:
        return singleFile(status, 0, viewImage);
      case 2:
        return fileRow(status, 0, viewImage);
      case 3:
        return Column(children: <Widget>[
          fileRow(status, 0, viewImage),
          singleFile(status, 2, viewImage),
        ]);
      case 4:
        return Column(children: <Widget>[
          fileRow(status, 0, viewImage),
          fileRow(status, 2, viewImage),
        ]);
      default:
        List<Widget> manyItems = [];

        manyItems.addAll([
          fileRow(status, 0, viewImage),
          fileRow(status, 2, viewImage),
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
                manyItems.add(fileRow(status, currentNumber, viewImage));
                currentNumber += 2;
              } else {
                remaining -= 1;
                manyItems.add(singleFile(status, currentNumber, viewImage));
                currentNumber += 1;
              }
            }
          }
        }

        return Column(children: manyItems);
    }
  }
}
