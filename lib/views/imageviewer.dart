import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter/material.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/definitions/attachment.dart';

Widget imageViewer(List<Attachment> attachments, int chosen) {
  List<PhotoViewGalleryPageOptions> pages =
      new List<PhotoViewGalleryPageOptions>();
  PageController pageController = new PageController(initialPage: chosen);

  for (Attachment attachment in attachments) {
    pages.add(PhotoViewGalleryPageOptions(
      imageProvider: NetworkImage(attachment.fileUrl),
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
