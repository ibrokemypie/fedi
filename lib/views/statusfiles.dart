import 'package:flutter/material.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/definitions/attachment.dart';
import 'package:fedi/views/imageviewer.dart';

class StatusFile extends StatefulWidget {
  final List<Attachment> files;
  final int fileNumber;
  final Function showImage;
  final bool isRow;

  StatusFile(this.files, this.fileNumber, this.showImage, this.isRow);
  @override
  StatusFileState createState() => new StatusFileState();
}

class StatusFileState extends State<StatusFile> {
  bool _isVisible;
  List<Attachment> _files;
  Attachment _file;
  Widget _toggleButton = Container();
  Widget _imageWidget;

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
    if (_file.thumbnailUrl != null &&
        _file.fileUrl != null &&
        _file.id != null) {
      if (_isVisible) {
        _imageWidget = Container(
            height: 200,
            color: Colors.grey[900],
            padding: EdgeInsets.all(5),
            child: Stack(
              children: <Widget>[
                Center(
                    child: FlatButton(
                      padding: EdgeInsets.all(0),
                  onPressed: () => widget.showImage(_files, widget.fileNumber),
                  child: Image.network(
                    _file.thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                )),
                _toggleButton
              ],
            ));
      } else {
        _imageWidget = Container(
            height: 200,
            child: InkWell(
                onTap: toggleVisible,
                child: Container(
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
                )));
      }
    } else {
      _imageWidget = Container(
        height: 200,
        color: Colors.grey[900],child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Image Missing",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return _imageWidget;
  }
}

Widget singleFile(Item status, int fileNumber, Function showImage) {
  return FractionallySizedBox(
        widthFactor: 1,
        child:Container(child:StatusFile(status.attachments, fileNumber, showImage, false)));
}

Widget fileRow(Item status, int startAt, Function showImage) {
  return  Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      Expanded(child:StatusFile(status.attachments, startAt, showImage, true)),
      Expanded(child:StatusFile(status.attachments, startAt + 1, showImage, true)),
    ],
  );
}

class StatusFiles extends StatelessWidget {
  final bool isContext;
  final Function moreButtonAction;
  final Item status;
  StatusFiles(this.isContext, this.moreButtonAction, this.status);

  @override
  Widget build(BuildContext context) {
    void viewImage(List<Attachment> files, int currentFile) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => imageViewer(files, currentFile)));
    }

    switch (status.attachments.length) {
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
          if (status.attachments.length > 4) {
            int remaining = status.attachments.length - 4;
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
