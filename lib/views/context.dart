import 'package:flutter/material.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/api/context.dart';
import 'package:fedi/views/item.dart';
import 'package:fedi/definitions/instance.dart';
import 'dart:async';

class StatusContext extends StatefulWidget {
  final Instance instance;
  final String authCode;
  final String statusId;
  final Item originalStatus;

  StatusContext(
      {this.instance, this.authCode, this.statusId, this.originalStatus});
  @override
  StatusContextState createState() => new StatusContextState();
}

class StatusContextState extends State<StatusContext> {
    ScrollController _scrollController = ScrollController();
  List<Item> statuses = new List();
  Widget contents = new Center(child: CircularProgressIndicator());

  Future<void> newStatuses() async {
    List<Item> statusList;

    statusList = await getContext(widget.instance, widget.authCode,
        widget.statusId, widget.originalStatus);

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
    List<Item> statusList = statuses.reversed.toList();
    return new ListView.builder(
      controller: _scrollController,
      itemBuilder: (context, i) {
        final index = i;
        if (index >= statusList.length) {
          return null;
        }
        return ItemBuilder(widget.instance, widget.authCode, statusList[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        child: contents,
        onRefresh: newStatuses,
      ),
    );
  }
}
