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
  final String lasttimeline;
  final Key key;

  TimeLine(
      {this.instance,
      this.authCode,
      this.timeline,
      this.statuses,
      this.inittimeline,
      this.lasttimeline,
      this.key});
  @override
  TimeLineState createState() => new TimeLineState();
}

class TimeLineState extends State<TimeLine> {
  Widget contents = new Center(child: CircularProgressIndicator());
  List<Item> _statuses = new List();

  @override
  void initState() {
    super.initState();
    widget.inittimeline(widget.timeline);
  }

  Widget statusListView() {
    return new ListView.builder(
      itemBuilder: (context, i) {
        final index = i;
        if (index >= _statuses.length) {
          return null;
        }
        return ItemBuilder(widget.instance, widget.authCode, _statuses[index],
            false, Key(_statuses[index].id));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.statuses == null || widget.statuses.length == 0 || (widget.lasttimeline != widget.timeline)) {
      print(widget.timeline);
      print(widget.lasttimeline);
      widget.inittimeline(widget.timeline);
    } else {
      setState(() {
        _statuses = widget.statuses;
        contents = statusListView();
      });
    }

    return contents;
  }
}
