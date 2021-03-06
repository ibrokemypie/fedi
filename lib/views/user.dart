import 'package:fedi/definitions/user.dart';
import 'package:flutter/material.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/api/getuser.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:fedi/views/timeline.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/definitions/relationship.dart';
import 'package:fedi/api/relationship.dart';
import 'package:fedi/api/followuser.dart';
import 'package:fedi/api/unfollowuser.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:fedi/api/gettimeline.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuple/tuple.dart';

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
  Relationship _relationship;
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

  _postTabs() {
    return TabBar(
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
    );
  }

  _tabChange() {
    try {
      setState(() {
        _currentTab = _tabNames[_postTabController.index];
      });
    } catch (e) {
      print(e);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
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
    Tuple3 timelineReturn;
    List<Item> statusList;
    try {
      timelineReturn = await getTimeline(_instance, _authCode, timeline,
          currentStatuses: _tabStatuses[timeline], sinceId: true);
      statusList = timelineReturn.item1;

      setState(() {
        _tabStatuses[timeline] = statusList;
        // _populateTabs();
        _initContents();
      });
    } catch (e) {
      print(e);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  Future<void> _oldStatuses(String timeline) async {
    Tuple3 timelineReturn;
    List<Item> statusList;
    try {
      timelineReturn = await getTimeline(_instance, _authCode, timeline,
          currentStatuses: _tabStatuses[timeline], untilId: true);
      statusList = timelineReturn.item1;

      setState(() {
        _tabStatuses[timeline] = statusList;
        // _populateTabs();
        _initContents();
      });
    } catch (e) {
      print(e);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  Future<bool> _initTimeline(String timeline) async {
    Tuple3 timelineReturn;
    List<Item> statusList;
    try {
      if (timeline != "user_pinned") {
        timelineReturn = await getTimeline(_instance, _authCode, timeline,
            targetUserId: _user.id);
        statusList = timelineReturn.item1;
      } else {
        if (_user.pinnedStatuses != null) {
          statusList = _user.pinnedStatuses;
        } else {
          timelineReturn = await getTimeline(_instance, _authCode, timeline,
              targetUserId: _user.id);
          statusList = timelineReturn.item1;
        }
      }

      setState(() {
        _tabStatuses[timeline] = statusList;
        _populateTabs();
        _initContents();
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

  _followUnfollow(String action) async {
    if (action == "follow") {
      await followUser(_instance, _authCode, _user.id);
    } else if (action == "unfollow") {
      await unFollowUser(_instance, _authCode, _user.id);
    }

    Relationship relationship =
        await getRelationship(_instance, _authCode, widget.userId);
    setState(() {
      _relationship = relationship;
      _initContents();
    });
  }

  Widget _followsYou() {
    if (_relationship.followingMe) {
      return Container(
        alignment: Alignment.center,
        width: 80,
        height: 25,
        child: Text(
          "Follows you",
          style: TextStyle(color: Colors.blue, fontSize: 12),
        ),
        decoration: BoxDecoration(
            borderRadius: new BorderRadius.all(Radius.circular(5)),
            border: Border.all(
                color: Colors.blue, style: BorderStyle.solid, width: 2)),
      );
    } else {
      return Container();
    }
  }

  Widget _followButton() {
    if (_user.id != _currentUser.id) {
      if (_relationship.followedByMe) {
        return FloatingActionButton(
          backgroundColor: Colors.red,
          child: Stack(
              overflow: Overflow.visible,
              alignment: Alignment.centerLeft,
              children: <Widget>[
                Positioned(
                    left: 13,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    )),
                Positioned(
                    left: 30,
                    bottom: 22,
                    child: Text(
                      "x",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )),
              ]),
          onPressed: () => _followUnfollow("unfollow"),
        );
      } else if (_relationship.requestedFollow != null &&
          _relationship.requestedFollow) {
        return FloatingActionButton(
          backgroundColor: Colors.red,
          child: Icon(
            Icons.hourglass_full,
            color: Colors.white,
          ),
          onPressed: () => _followUnfollow("unfollow"),
        );
      } else {
        return FloatingActionButton(
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.person_add,
            color: Colors.white,
          ),
          onPressed: () => _followUnfollow("follow"),
        );
      }
    } else {
      return Container();
    }
  }

  Widget _bio() {
    String html = markdown.markdownToHtml(_user.description);
    String bio = html;

    return SliverToBoxAdapter(
        child: Container(
            color: Colors.grey[800],
            child: Column(children: <Widget>[
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
                    right: 16.0,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          ClipRRect(
                              borderRadius: new BorderRadius.circular(10.0),
                              child: Container(
                                child: Image(
                                    image: CachedNetworkImageProvider(
                                        _user.avatarUrl),
                                    height: 80.0,
                                    width: 80.0,
                                    fit: BoxFit.cover),
                                color: Colors.grey[900],
                              )),
                          _followButton(),
                        ]),
                  )
                ],
              ),
              Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _user.nickname,
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "@" + _user.acct,
                                style: TextStyle(
                                    fontSize: 14.0, color: Colors.grey[100]),
                              ),
                            ],
                          )),
                      _followsYou(),
                      Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Html(
                            data: bio,
                            defaultTextStyle:
                                TextStyle(color: Colors.grey[350]),
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
            ])));
  }

  _initContents() {
    setState(() {
      _contents = NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
          return <Widget>[
            _bio(),
            SliverAppBar(
              pinned: true,
              floating: true,
              actions: <Widget>[],
              expandedHeight: 0,
              leading: new Container(),
              forceElevated: boxIsScrolled,
              backgroundColor: Colors.grey[600],
              bottom: _postTabs(),
            )
          ];
        },
        body: TabBarView(
          controller: _postTabController,
          children: _postTabWidgets,
        ),
      );
    });
  }

  _populateTabs() {
    List<Widget> _newWidgets = new List();
    for (String tab in _tabNames) {
      _newWidgets.add(_timelineWidget(tab));
    }
    _postTabWidgets = _newWidgets;
  }

  _initialiseWidget() async {
    try {
      User newUser = await getUserFromId(_instance, widget.userId);
      Relationship relationship =
          await getRelationship(_instance, _authCode, widget.userId);
      setState(() {
        _user = newUser;
        _relationship = relationship;

        _postTabController.addListener(_tabChange);
        _currentTab = _tabNames.elementAt(_postTabController.index);
        _initTabStatuses();
        _populateTabs();
        _initContents();
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
      _tabNames =
          new List.of(["user", "user_replies", "user_media", "user_pinned"]);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(key: _scaffoldKey, appBar: AppBar(), body: _contents);
  }
}
