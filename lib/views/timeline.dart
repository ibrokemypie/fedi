import 'package:flutter/material.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/api/hometimeline.dart';
import 'package:fedi/api/publictimeline.dart';
import 'package:fedi/api/localtimeline.dart';
import 'package:fedi/views/item.dart';
import 'package:fedi/definitions/instance.dart';
import 'dart:async';

class TimeLine extends StatefulWidget {
  final Instance instance;
  final String authCode;
  final String timeline;

  TimeLine({this.instance, this.authCode, this.timeline});
  @override
  TimeLineState createState() => new TimeLineState();
}

class TimeLineState extends State<TimeLine> {
  List<Item> statuses = new List();
  Widget contents = new Center(child: CircularProgressIndicator());
  var _timelineCommand;

  Future<void> newStatuses() async {
    List<Item> statusList;
    if (statuses.length > 0) {
      statusList = await _timelineCommand(widget.instance, widget.authCode,
          currentStatuses: statuses, sinceId: statuses[0].id);
    } else {
      statusList = await _timelineCommand(widget.instance, widget.authCode);
    }
    try {
      setState(() {
        statuses = statusList;
        contents = statusListView();
      });
    } catch (e) {}
  }

  void _determineTimeline() {
    print(widget.timeline);
    setState(() {
      switch (widget.timeline) {
        case "home":
          _timelineCommand = getHomeTimeline;
          break;
        case "local":
          _timelineCommand = getLocalTimeline;
          break;
        case "public":
          _timelineCommand = getMisskeyPublicTimeline;
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _determineTimeline();
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
