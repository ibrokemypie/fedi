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
  final Function inittimeline;
  final User currentUser;
  final Key key;

  TimeLine(
      {this.instance,
      this.authCode,
      this.statuses,
      this.inittimeline,
      this.currentUser,
      this.key});
  @override
  TimeLineState createState() => new TimeLineState();
}

class TimeLineState extends State<TimeLine> {
  Widget contents = SizedBox(
      height: 300, child: new Center(child: CircularProgressIndicator()));
  List<Item> _statuses = new List();

  @override
  void initState() {
    super.initState();
  }

  Widget statusColumn() {
    List<Widget> statusItems = new List();
    for (Item status in _statuses) {
      statusItems.add(ItemBuilder(
          instance: widget.instance,
          authCode: widget.authCode,
          item: status,
          isContext: false,
          currentUser: widget.currentUser,
          key: Key(status.id)));
    }

    return Column(children: statusItems);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.statuses == null || widget.statuses.length == 0) {
      widget.inittimeline();
    } else {
      setState(() {
        _statuses = widget.statuses;
         contents = statusColumn();
      });
    }

    return contents;
  }
}
