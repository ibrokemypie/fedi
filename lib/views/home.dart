import 'package:flutter/material.dart';
import 'package:fedi/views/post.dart';
import 'package:fedi/views/timeline.dart';
import 'package:fedi/views/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/definitions/item.dart';
import 'dart:async';
import 'dart:collection';
import 'package:fedi/api/gettimeline.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  Instance instance;
  String authCode;

  TabController _tabController;
  String _currentTab;
  String _lastTab;

  List<String> _tabNames;
  Map<String, List<Item>> _tabStatuses;
  List<Widget> _tabWidgets = new List.of([
    new Center(
      child: CircularProgressIndicator(),
    ),
    new Center(
      child: CircularProgressIndicator(),
    ),
    new Center(
      child: CircularProgressIndicator(),
    ),
    new Center(
      child: CircularProgressIndicator(),
    ),
  ]);

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
      _newlist.addAll(_tabStatuses[_currentTab]);
      _tabStatuses[_currentTab] = _newlist;
    });
  }

  Future<void> _newStatuses() async {
    List<Item> statusList;
    statusList = await getTimeline(instance, authCode, _currentTab);

    try {
      setState(() {
        _tabStatuses[_currentTab] = statusList;
        _populateTabs();
        // contents = statusListView();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<bool> _initTimeline() async {
    List<Item> statusList;
    print("timeline" + _currentTab);
    statusList = await getTimeline(instance, authCode, _currentTab);
    try {
      setState(() {
        _tabStatuses[_currentTab] = statusList;
        _populateTabs();
      });
    } catch (e) {
      print(e);
      return false;
    }
    return true;
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

        _tabController.addListener(_tabChange);
        _currentTab = _tabNames.elementAt(_tabController.index);
        _lastTab = "none";

        _populateTabs();
      });
    }
  }

  _tabChange() {
    setState(() {
      _lastTab = _currentTab;
      _currentTab = _tabNames[_tabController.index];
      print("last tab: " + _lastTab + " current tab: " + _currentTab);
    });
  }

  _timelineWidget(String timelineName) {
    return new RefreshIndicator(
      child: TimeLine(
        instance: instance,
        authCode: authCode,
        statuses: _tabStatuses[timelineName],
        inittimeline: _initTimeline,
      ),
      key: Key(timelineName),
      onRefresh: () => _newStatuses(),
    );
  }

  _populateTabs() {
    List<Widget> newtabs = new List();
    for (String name in _tabNames) {
      newtabs.add(_timelineWidget(name));
    }
    setState(() {
      _tabWidgets = newtabs;
    });
  }

  _initTabStatuses() {
    Map<String, List<Item>> newtabstatuses = new Map();
    for (String name in _tabNames) {
      newtabstatuses.addAll({name: new List<Item>()});
    }
    setState(() {
      _tabStatuses = newtabstatuses;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _tabNames = new List.of(["home", "notifications", "local", "public"]);
      _tabController = TabController(vsync: this, length: _tabNames.length);
    });
    _initTabStatuses();
    verifyAuth();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: _tabController,
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
        controller: _tabController,
        children: _tabWidgets,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _postStatus,
        child: Icon(Icons.edit),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }
}
