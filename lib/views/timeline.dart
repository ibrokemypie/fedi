import 'package:flutter/material.dart';
import 'package:fedi/definitions/status.dart';
import 'package:fedi/definitions/user.dart';
import 'package:fedi/api/hometimeline.dart';
import 'package:fedi/views/status.dart';
import 'package:fedi/views/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fedi/definitions/instance.dart';
import 'dart:convert';

class TimeLine extends StatefulWidget {
  final Instance instance;
  final String authCode;
  // static Instance instance;

  TimeLine({this.instance,this.authCode});
  @override
  TimeLineState createState() => new TimeLineState();
}

class TimeLineState extends State<TimeLine> {
  List<Status> statuses = new List();


  Future<void> newStatuses() async {
    List<Status> statusList;
    if (statuses.length > 0) {
      statusList = await getHomeTimeline(widget.instance, widget.authCode,
          currentStatuses: statuses, sinceId: statuses[0].id);
    } else {
      statusList = await getHomeTimeline(widget.instance, widget.authCode);
    }
    setState(() {
      statuses = statusList;
    });
  }

  @override
  void initState() {
    super.initState();
    newStatuses();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: new ListView.builder(
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          if (index >= statuses.length) {
            return null;
          }
          return statusBuilder(statuses[index]);
        },
      ),
      onRefresh: newStatuses,
    );
  }
}
