import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter/material.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/definitions/file.dart';

Widget imageViewer(List<File> files, int chosen) {
  List<PhotoViewGalleryPageOptions> pages =
      new List<PhotoViewGalleryPageOptions>();
  PageController pageController = new PageController(initialPage: chosen);

  for (File file in files) {
    pages.add(PhotoViewGalleryPageOptions(
      imageProvider: NetworkImage(file.fileUrl),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 1.8,
    ));
  }

  return Container(
    child: PhotoViewGallery(
      pageOptions: pages,
      backgroundDecoration: BoxDecoration(color: Colors.black87),
      pageController: pageController,
    ),
  );
}
