import 'package:photo_view/photo_view.dart';
import 'package:flutter/material.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/definitions/file.dart';

Widget imageViewer(List<File> files, int chosen) {
  return Container(
    child: PhotoView(
      imageProvider: NetworkImage(files[chosen].fileUrl),
      backgroundDecoration: BoxDecoration(color: Colors.black87),
      loadingChild: Image.network(files[chosen].thumbnailUrl),
    ),
  );
}
