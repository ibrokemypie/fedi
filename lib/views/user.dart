import 'package:fedi/definitions/user.dart';
import 'package:flutter/material.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/api/getuser.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/views/statusbody.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:cached_network_image/cached_network_image.dart';

class UserProfile extends StatefulWidget {
  final String userId;
  final Instance instance;

  UserProfile({this.userId, this.instance});
  @override
  UserProfileState createState() => new UserProfileState();
}

class UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  User _user;
  TabController _tabController;
  Widget _contents = new Center(child: CircularProgressIndicator());
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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

  _initialiseWidget() async {
    try {
      User newUser = await getUserFromId(widget.instance, widget.userId);
      setState(() {
        _user = newUser;
        _contents = ListView(
          children: <Widget>[
            _bio(),
          ],
        );
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
      _tabController = TabController(vsync: this, length: 4);
    });
    _initialiseWidget();
  }

  _tabs() {
    return TabBar(
      controller: _tabController,
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

  _tabViews() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        Container(),
        Container(),
        Container(),
        Container(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(key: _scaffoldKey, appBar: AppBar(), body: _contents);
  }
}
