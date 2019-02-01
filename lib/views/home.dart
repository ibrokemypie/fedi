import 'package:flutter/material.dart';
import 'package:fedi/views/post.dart';
import 'package:fedi/views/timeline.dart';
import 'package:fedi/views/notifications.dart';
import 'package:fedi/views/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/definitions/item.dart';
import 'dart:async';

class Home extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State {
  Instance instance;
  String authCode;

  List<Item> statuses = new List();

  Widget tabOne = new Center(
    child: CircularProgressIndicator(),
  );
  Widget tabTwo = new Center(
    child: CircularProgressIndicator(),
  );
  Widget tabThree = new Center(
    child: CircularProgressIndicator(),
  );
  Widget tabFour = new Center(
    child: CircularProgressIndicator(),
  );

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('authenticated', false);
    prefs.setString('userAuth', null);
    prefs.setString('instance', null);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LogIn()));
  }

  void _postStatus() async {
    final _newStatus = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Post(
                  instance: instance,
                  authCode: authCode,
                )));
    setState(() {
      List<Item> _newlist = List();
      _newlist.add(_newStatus);
      _newlist.addAll(statuses);
      statuses = _newlist;
    });
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
      setState(() {
        instance = newInstance;
        authCode = userAuth;
        tabOne = TimeLine(
          instance: instance,
          authCode: authCode,
          timeline: "home",
          statuses: statuses,
        );
        tabTwo = Notifications(
          instance: instance,
          authCode: authCode,
        );
        tabThree = TimeLine(
          instance: instance,
          authCode: authCode,
          timeline: "local",
          statuses: statuses,
        );
        tabFour = TimeLine(
          instance: instance,
          authCode: authCode,
          timeline: "public",
          statuses: statuses,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    verifyAuth();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.notifications)),
              Tab(icon: Icon(Icons.people)),
              Tab(icon: Icon(Icons.public)),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              // TODO: rest of the drawer
              // TODO: user header
              ListTile(
                title: Text('Logout'),
                onTap: () {
                  _logout(context);
                },
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            tabOne,
            tabTwo,
            tabThree,
            tabFour,
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _postStatus,
          child: Icon(Icons.edit),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
