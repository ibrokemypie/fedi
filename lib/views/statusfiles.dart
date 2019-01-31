import 'package:flutter/material.dart';
import 'package:fedi/definitions/item.dart';

Widget statusFile(String thumbnailUrl, String fileUrl) {
  return Image.network(
    thumbnailUrl,
    fit: BoxFit.contain,
  );
}

Widget singleFile(Item status, int fileNumber) {
  return Container(
      child: statusFile(status.files[fileNumber].thumbnailUrl,
          status.files[fileNumber].fileUrl));
}

Widget fileRow(Item status, int startAt) {
  return FittedBox(
      child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      statusFile(
          status.files[startAt].thumbnailUrl, status.files[startAt].fileUrl),
      statusFile(status.files[startAt + 1].thumbnailUrl,
          status.files[startAt + 1].fileUrl),
    ],
  ));
}

Widget statusFiles(Function moreButtonAction,Item status) {
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
      return Column(children: <Widget>[
        fileRow(status, 0),
        fileRow(status, 2),
        Container(
          // width: double.infinity,
          child: FlatButton(
            color: Colors.grey,
            onPressed: moreButtonAction,
            child: Center(child: Text("More")),
          ),
        ),
      ]);
  }
}
