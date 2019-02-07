import 'package:flutter/material.dart';
import 'package:fedi/views/post.dart';
import 'package:fedi/views/timeline.dart';
import 'package:fedi/views/login.dart';
import 'package:fedi/views/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/definitions/user.dart';
import 'dart:async';
import 'dart:convert';
import 'package:fedi/api/gettimeline.dart';
import 'package:fedi/api/getcurrentuser.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State<Home> with TickerProviderStateMixin {
  Instance _instance;
  String _authCode;
  User _currentUser = new User();

  TabController _tabController;
  String _currentTab;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  AnimationController _dropdownButtonRotations;
  bool _dropdownOpen = false;

  Function _newButton;

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
    prefs.setString('currentUser', null);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LogIn()));
  }

  void _postStatus() async {
    final _newStatus = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Post(
                  instance: _instance,
                  authCode: _authCode,
                )));
    setState(() {
      List<Item> _newlist = List();
      _newlist.add(_newStatus);
      _newlist.addAll(_tabStatuses[_currentTab]);
      _tabStatuses[_currentTab] = _newlist;
    });
  }

  Future<void> _newStatuses(String timeline) async {
    List<Item> statusList;
    try {
      statusList = await getTimeline(_instance, _authCode, timeline,
          currentStatuses: _tabStatuses[timeline],
          sinceId: _tabStatuses[timeline][0].id);

      setState(() {
        _tabStatuses[timeline] = statusList;
        _populateTabs();
      });
    } catch (e) {
      print(e);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  Future<void> _oldStatuses(String timeline) async {
    List<Item> statusList;
    try {
      statusList = await getTimeline(_instance, _authCode, timeline,
          currentStatuses: _tabStatuses[timeline],
          untilId: _tabStatuses[timeline].last.id);

      setState(() {
        _tabStatuses[timeline] = statusList;
        _populateTabs();
      });
    } catch (e) {
      print(e);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  Future<bool> _initTimeline(String timeline) async {
    List<Item> statusList;
    try {
      statusList = await getTimeline(_instance, _authCode, timeline);

      setState(() {
        _tabStatuses[timeline] = statusList;
        _populateTabs();
      });
    } catch (e) {
      print(e);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
      return false;
    }
    return true;
  }

  Future<void> verifyAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var auth = prefs.getBool('authenticated') ?? false;
    var userAuth = prefs.getString('userAuth') ?? null;
    var instanceUrl = prefs.getString('instance') ?? null;
    var currentUser;
    if (prefs.getString('currentUser') != null) {
      currentUser = json.decode(prefs.getString('currentUser')) ?? null;
    } else {
      currentUser = null;
    }

    if (auth == false || userAuth == null || instanceUrl == null) {
      _logout(context);
    } else {
      try {
        Instance newInstance = await Instance.fromUrl(instanceUrl);

        setState(() {
          _instance = newInstance;
          _authCode = userAuth;
        });

        if (currentUser == null) {
          currentUser = await getCurrentUser(_instance, _authCode);
        }

        if (currentUser == null) {
          _logout(context);
        } else {
          setState(() {
            _currentUser = currentUser;

            print(_currentUser.username);

            _tabController.addListener(_tabChange);
            _currentTab = _tabNames.elementAt(_tabController.index);

            _newButton = _postStatus;

            _populateTabs();
          });
        }
      } catch (e) {
        print(e);
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      }
    }
  }

  _tabChange() {
    setState(() {
      _currentTab = _tabNames[_tabController.index];
    });
  }

  _timelineWidget(String timelineName) {
    return new RefreshIndicator(
      child: TimeLine(
        instance: _instance,
        authCode: _authCode,
        statuses: _tabStatuses[timelineName],
        initTimeline: () => _initTimeline(timelineName),
        currentUser: _currentUser,
        newStatuses: () => _newStatuses(timelineName),
        oldStatuses: () => _oldStatuses(timelineName),
      ),
      key: Key(timelineName),
      onRefresh: () => _newStatuses(timelineName),
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

  _toggleHeaderDropdown() {
    if (_dropdownOpen) {
      setState(() {
        _dropdownOpen = !_dropdownOpen;
        _dropdownButtonRotations.forward();
      });
    } else {
      setState(() {
        _dropdownOpen = !_dropdownOpen;
        _dropdownButtonRotations.reverse();
      });
    }
  }

  _showUserPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserProfile(
                  instance: _instance,
                  userId: _currentUser.id,
                  currentUser: _currentUser,
                  authCode: _authCode,
                )));
  }

  _appDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          // TODO: rest of the drawer
          DrawerHeader(
              padding: EdgeInsets.all(0),
              child: Stack(children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: CachedNetworkImageProvider(_currentUser.bannerUrl),
                    fit: BoxFit.cover,
                  )),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          child: GestureDetector(
                            child: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  _currentUser.avatarUrl),
                              radius: 28,
                            ),
                            onTap: _showUserPage,
                          )),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            _currentUser.nickname,
                            style: TextStyle(fontSize: 24),
                          )),
                      Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "@" + _currentUser.acct,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[100]),
                              ),
                              RotationTransition(
                                turns: _dropdownButtonRotations,
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  size: 18,
                                ),
                              )
                            ],
                          )),
                    ],
                  ),
                ),
                // Material(
                //   type: MaterialType.transparency,
                //   child: FlatButton(
                //     child: Container(),
                //     onPressed: _toggleHeaderDropdown,
                //   ),
                // ),
              ])),
          ListTile(
            title: Text('Logout'),
            onTap: () {
              _logout(context);
            },
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _tabNames = new List.of(["home", "notifications", "local", "public"]);
      _tabController = TabController(vsync: this, length: _tabNames.length);
    });
    _dropdownButtonRotations = AnimationController(
        lowerBound: 0,
        upperBound: .5,
        vsync: this,
        duration: Duration(milliseconds: 100));

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
      key: _scaffoldKey,
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
      drawer: _appDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: _tabWidgets,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newButton,
        child: Icon(Icons.edit),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }
}
