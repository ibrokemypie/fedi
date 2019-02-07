import 'package:flutter/material.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/views/item.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/definitions/user.dart';
import 'package:fedi/api/gettimeline.dart';
import 'dart:async';

class TimeLine extends StatefulWidget {
  final Instance instance;
  final String authCode;
  final List<Item> statuses;
  final Function initTimeline;
  final Function newStatuses;
  final Function oldStatuses;
  final User currentUser;
  final Key key;

  TimeLine(
      {this.instance,
      this.authCode,
      this.statuses,
      this.initTimeline,
      this.newStatuses,
      this.oldStatuses,
      this.currentUser,
      this.key});
  @override
  TimeLineState createState() => new TimeLineState();
}

class TimeLineState extends State<TimeLine> {
  Widget contents = new Center(child: CircularProgressIndicator());
  List<Item> _statuses = new List();
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (_controller.position.atEdge) {
        if (_controller.position.pixels != 0) widget.oldStatuses();
      }
    });
  }

  Widget statusListView() {
    return new ListView.builder(
      controller: _controller,
      itemBuilder: (context, i) {
        final index = i;
        if (index >= _statuses.length) {
          return null;
        }
        return ItemBuilder(
            instance: widget.instance,
            authCode: widget.authCode,
            item: _statuses[index],
            isContext: false,
            currentUser: widget.currentUser,
            key: Key(_statuses[index].id));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.statuses == null || widget.statuses.length == 0) {
      widget.initTimeline();
    } else {
      setState(() {
        _statuses = widget.statuses;
        contents = statusListView();
      });
    }

    return contents;
  }
}
