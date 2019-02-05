import 'package:fedi/definitions/user.dart';
import 'package:flutter/material.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/api/getuser.dart';
import 'dart:async';
import 'package:fedi/views/usertimeline.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/views/statusbody.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:fedi/api/gettimeline.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sticky_headers/sticky_headers.dart';

class UserProfile extends StatefulWidget {
  final String userId;
  final Instance instance;
  final String authCode;
  final User currentUser;

  UserProfile({this.userId, this.instance, this.authCode, this.currentUser});
  @override
  UserProfileState createState() => new UserProfileState();
}

class UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  User _user;
  Instance _instance;
  String _authCode;
  TabController _postTabController;
  String _currentTab;
  User _currentUser;
  Widget _contents = new Center(child: CircularProgressIndicator());
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<String> _tabNames;
  Map<String, List<Item>> _tabStatuses;

  List<Widget> _postTabWidgets = new List.of([
    Center(
      child: CircularProgressIndicator(),
    ),
    Center(
      child: CircularProgressIndicator(),
    ),
    Center(
      child: CircularProgressIndicator(),
    ),
    Center(
      child: CircularProgressIndicator(),
    ),
  ]);

  _tabChange() {
    setState(() {
      _currentTab = _tabNames[_postTabController.index];
    });
  }

  _timelineWidget(String timelineName) {
    return new RefreshIndicator(
      child: TimeLine(
        instance: _instance,
        authCode: _authCode,
        statuses: _tabStatuses[timelineName],
        inittimeline: () => _initTimeline(timelineName),
        currentUser: _currentUser,
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
      _postTabWidgets = newtabs;
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

  Future<void> _newStatuses(String timeline) async {
    List<Item> statusList;
    try {
      statusList = await getTimeline(_instance, _authCode, timeline,
          targetUserId: _user.id);

      setState(() {
        _tabStatuses[timeline] = statusList;
        _populateTabs();
        _populateContents();
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
      if (timeline != "pinned") {
        statusList = await getTimeline(_instance, _authCode, timeline,
            targetUserId: _user.id);
      } else {
        if (_user.pinnedStatuses != null) {
          statusList = _user.pinnedStatuses;
        }
      }

      setState(() {
        _tabStatuses[timeline] = statusList;
        _populateTabs();
        _populateContents();
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

  _bio() {
    String html = markdown.markdownToHtml(_user.description);
    String bio = html;
    return Column(children: <Widget>[
      Stack(
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(bottom: 40.0),
              child: Image(
                image: CachedNetworkImageProvider(_user.bannerUrl),
                fit: BoxFit.cover,
                height: 128,
                width: double.infinity,
              )),
          Positioned(
            bottom: 0.0,
            left: 16.0,
            child: ClipRRect(
                borderRadius: new BorderRadius.circular(10.0),
                child: Container(
                  child: Image(
                      image: CachedNetworkImageProvider(_user.avatarUrl),
                      height: 80.0,
                      width: 80.0,
                      fit: BoxFit.cover),
                  color: Colors.grey[900],
                )),
          )
        ],
      ),
      Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _user.nickname,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "@" + _user.acct,
                        style:
                            TextStyle(fontSize: 14.0, color: Colors.grey[100]),
                      ),
                    ],
                  )),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Html(
                    data: bio,
                    defaultTextStyle: TextStyle(color: Colors.grey[350]),
                    renderNewlines: false,
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        _user.followersCount.toString() + "\nFollowers",
                        textAlign: TextAlign.center,
                      )),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        _user.followingCount.toString() + "\nFollows",
                        textAlign: TextAlign.center,
                      )),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        _user.statusCount.toString() + "\nPosts",
                        textAlign: TextAlign.center,
                      )),
                ],
              )
            ],
          )),
    ]);
  }

  _populateContents() {
    _contents = SingleChildScrollView(
        child: Column(
      children: <Widget>[
        _bio(),
        StickyHeader(
          header: _postTabs(),
          content: _postTabViews(),
        ),
      ],
    ));
  }

  _initialiseWidget() async {
    try {
      User newUser = await getUserFromId(widget.instance, widget.userId);
      setState(() {
        _user = newUser;

        _postTabController.addListener(_tabChange);
        _currentTab = _tabNames.elementAt(_postTabController.index);

        _populateTabs();
        _populateContents();
      });
    } catch (e) {
      print(e);
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _instance = widget.instance;
      _authCode = widget.authCode;
      _currentUser = widget.currentUser;
      _tabNames = new List.of(["user", "user_replies", "user_media", "pinned"]);
      _postTabController = TabController(vsync: this, length: 4);
    });

    _initTabStatuses();
    _initialiseWidget();
  }

  @override
  void dispose() {
    _postTabController.dispose();
    super.dispose();
  }

  _postTabs() {
    return Container(
        color: Colors.grey,
        child: TabBar(
          controller: _postTabController,
          tabs: <Widget>[
            Tab(
              child: Text("Posts"),
            ),
            Tab(
              child: Text("With Replies"),
            ),
            Tab(
              child: Text("Media"),
            ),
            Tab(
              child: Text("Pinned"),
            ),
          ],
        ));
  }

  _postTabViews() {
    return Container(
        child: Container(
            height: double.maxFinite,
            child: TabBarView(
              controller: _postTabController,
              children: _postTabWidgets,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(key: _scaffoldKey, appBar: AppBar(), body: _contents);
  }
}
