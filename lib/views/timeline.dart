import 'package:flutter/material.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/views/item.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/api/gettimeline.dart';
import 'dart:async';

class TimeLine extends StatefulWidget {
  final Instance instance;
  final String authCode;
  final String timeline;
  final List<Item> statuses;
  final Function inittimeline;
  final Key key;

  TimeLine(
      {this.instance,
      this.authCode,
      this.timeline,
      this.statuses,
      this.inittimeline,
      this.key});
  @override
  TimeLineState createState() => new TimeLineState();
}

class TimeLineState extends State<TimeLine> {
  Widget contents = new Center(child: CircularProgressIndicator());
  List<Item> _statuses = new List();

  Future<void> _newStatuses() async {
    List<Item> statusList;
    statusList =
        await getTimeline(widget.instance, widget.authCode, widget.timeline);

    try {
      setState(() {
        _statuses = statusList;
        contents = statusListView();
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget statusListView() {
    return new ListView.builder(
      itemBuilder: (context, i) {
        final index = i;
        if (index >= _statuses.length) {
          return null;
        }
        return ItemBuilder(
            widget.instance, widget.authCode, _statuses[index], false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.statuses == null || widget.statuses.length == 0) {
      widget.inittimeline(widget.timeline);
    } else {
      setState(() {
        _statuses = widget.statuses;
        contents = statusListView();
      });
    }

    return RefreshIndicator(
      child: contents,
      onRefresh: _newStatuses,
    );
  }
}
