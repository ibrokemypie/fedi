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
  @override
  TimeLineState createState() => new TimeLineState();
}

class TimeLineState extends State {
  Instance instance;
  String authCode;
  List<Status> statuses = new List();

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('authenticated', false);
    prefs.setString('userAuth', null);
    prefs.setString('instance', null);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LogIn()));
  }

  Future<void> verifyAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var auth = prefs.getBool('authenticated') ?? false;
    var userAuth = prefs.getString('userAuth') ?? null;
    var instanceUrl = prefs.getString('instance') ?? null;

    if (auth == false || userAuth == null || instanceUrl == null) {
      _logout(context);
    } else {
      Instance newInstance = await Instance.fromUrl(instanceUrl);
      List statusList = await getHomeTimeline(newInstance, userAuth);
      setState(() {
        instance = newInstance;
        authCode = userAuth;
        statuses = statusList;
      });
    }
  }

  Future<void> newStatuses() async {
    List<Status> statusList;
    if (statuses.length > 0) {
      statusList = await getHomeTimeline(instance, authCode,
          currentStatuses: statuses, sinceId: statuses[0].id);
    } else {
      statusList = await getHomeTimeline(instance, authCode);
    }
    setState(() {
      statuses = statusList;
    });
  }

  @override
  void initState() {
    super.initState();
    verifyAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new RefreshIndicator(
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
      ),
      drawer: Drawer(),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _logout(context);
            },
          )
        ],
      ),
    );
  }
}
