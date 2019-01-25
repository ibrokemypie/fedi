import 'package:flutter/material.dart';
import 'package:fedi/api/notifications.dart';
import 'package:fedi/definitions/notification.dart';
// import 'package:fedi/views/notification.dart';
import 'package:fedi/definitions/instance.dart';
import 'dart:async';

class Notifications extends StatefulWidget {
  final Instance instance;
  final String authCode;
  // static Instance instance;

  Notifications({this.instance, this.authCode});
  @override
  NotificationsState createState() => new NotificationsState();
}

class NotificationsState extends State<Notifications> {
  List<FediNotification> notifications = new List();
  Widget contents = new Center(child: CircularProgressIndicator());

  Future<void> newNotifications() async {
    List<FediNotification> notificationList;
    if (notifications.length > 0) {
      notificationList = await getNotifications(widget.instance, widget.authCode,
          currentNotifications: notifications);
    } else {
      notificationList = await getNotifications(widget.instance, widget.authCode);
    }
    setState(() {
      notifications = notificationList;
      contents = notificationsListView();
    });
  }

  @override
  void initState() {
    super.initState();
    newNotifications();
  }

  Widget notificationsListView() {
    return new ListView.builder(
      itemBuilder: (context, i) {
        final index = i;
        if (index >= notifications.length) {
          return null;
        }
        // if (notifications[index].renote != null) {
        //   return RenoteBuilder(
        //       widget.instance, widget.authCode, notifications[index]);
        // } else {
        //   return StatusBuilder(
        //       widget.instance, widget.authCode, statuses[index]);
        // }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: contents,
      onRefresh: newNotifications,
    );
  }
}
