import 'package:flutter/material.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/api/hometimeline.dart';
import 'package:fedi/views/item.dart';
import 'package:fedi/definitions/instance.dart';
import 'dart:async';

class TimeLine extends StatefulWidget {
  final Instance instance;
  final String authCode;
  // static Instance instance;

  TimeLine({this.instance, this.authCode});
  @override
  TimeLineState createState() => new TimeLineState();
}

class TimeLineState extends State<TimeLine> {
  List<Item> statuses = new List();
  Widget contents = new Center(child: CircularProgressIndicator());

  Future<void> newStatuses() async {
    List<Item> statusList;
    if (statuses.length > 0) {
      statusList = await getHomeTimeline(widget.instance, widget.authCode,
          currentStatuses: statuses, sinceId: statuses[0].id);
    } else {
      statusList = await getHomeTimeline(widget.instance, widget.authCode);
    }
    setState(() {
      statuses = statusList;
      contents = statusListView();
    });
  }

  @override
  void initState() {
    super.initState();
    newStatuses();
  }

  Widget statusListView() {
    return new ListView.builder(
      itemBuilder: (context, i) {
        final index = i;
        if (index >= statuses.length) {
          return null;
        }
        return ItemBuilder(widget.instance, widget.authCode, statuses[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: contents,
      onRefresh: newStatuses,
    );
  }
}
