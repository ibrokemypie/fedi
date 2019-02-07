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

  @override
  void initState() {
    super.initState();

  }

  Widget statusListView() {
    return new ListView.builder(
      itemBuilder: (context, index) {
        if (index == _statuses.length) {
          return new RefreshIndicatorItem(widget.oldStatuses);
        }

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

class RefreshIndicatorItem extends StatefulWidget {
  final Function oldStatuses;

  RefreshIndicatorItem(this.oldStatuses);
  @override
  RefreshIndicatorItemState createState() => new RefreshIndicatorItemState();
}

class RefreshIndicatorItemState extends State<RefreshIndicatorItem> {
  @override
  void initState() {
    super.initState();
    widget.oldStatuses();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
