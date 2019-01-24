import 'package:flutter/material.dart';
import 'package:fedi/definitions/status.dart';
import 'package:fedi/definitions/user.dart';
import 'package:fedi/api/hometimeline.dart';
import 'package:fedi/views/status.dart';
import 'package:fedi/views/post.dart';
import 'package:fedi/views/timeline.dart';
import 'package:fedi/views/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fedi/definitions/instance.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State {
  Instance instance;
  String authCode;
  Widget tabOne = new Center(
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
              Tab(icon: Icon(Icons.message)),
              Tab(icon: Icon(Icons.public)),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
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
            Icon(Icons.notifications),
            Icon(Icons.message),
            Icon(Icons.public),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => Post())),
          child: Icon(Icons.edit),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
