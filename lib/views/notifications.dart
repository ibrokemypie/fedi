import 'package:flutter/material.dart';
import 'package:fedi/api/notifications.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/views/item.dart';
import 'package:fedi/definitions/instance.dart';
import 'dart:async';

class Notifications extends StatefulWidget {
  final Instance instance;
  final String authCode;

  Notifications({this.instance, this.authCode});
  @override
  NotificationsState createState() => new NotificationsState();
}

class NotificationsState extends State<Notifications> {
  List<Item> notifications = new List();
  Widget contents = new Center(child: CircularProgressIndicator());

  Future<void> newNotifications() async {
    List<Item> notificationList;
    if (notifications.length > 0) {
      notificationList = await getNotifications(
          widget.instance, widget.authCode,
          currentNotifications: notifications);
    } else {
      notificationList =
          await getNotifications(widget.instance, widget.authCode);
    }
    try {
      setState(() {
        notifications = notificationList;
        contents = notificationsListView();
      });
    } catch (e) {}
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
        if (notifications[index] != null) {
          return ItemBuilder(
              widget.instance, widget.authCode, notifications[index],false);
        }
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
