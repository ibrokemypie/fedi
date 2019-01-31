import 'package:flutter/material.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/definitions/file.dart';
import 'package:photo_view/photo_view.dart';

Widget statusFile(File file) {
  if (!file.sensitive) {
    return Image.network(
      file.thumbnailUrl,
      fit: BoxFit.contain,
    );
  }
}

Widget singleFile(Item status, int fileNumber) {
  return Container(child: statusFile(status.files[fileNumber]));
}

Widget fileRow(Item status, int startAt) {
  return FittedBox(
      child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      statusFile(status.files[startAt]),
      statusFile(status.files[startAt + 1]),
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
