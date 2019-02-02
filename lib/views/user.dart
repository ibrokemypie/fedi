import 'package:fedi/definitions/user.dart';
import 'package:flutter/material.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/views/statusbody.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as markdown;

class UserProfile extends StatefulWidget {
  final User user;
  final Instance instance;

  UserProfile({this.user, this.instance});
  @override
  UserProfileState createState() => new UserProfileState();
}

class UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  User _user;
  TabController _tabController;

  _bio() {
    String html = markdown.markdownToHtml(_user.description);
    String bio = html;
    return Column(children: <Widget>[
      Stack(
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(bottom: 40.0),
              child: Image(
                image: NetworkImage(_user.bannerUrl),
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
                  child: Image.network(_user.avatarUrl,
                      height: 80.0, width: 80.0, fit: BoxFit.cover),
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

  @override
  void initState() {
    super.initState();
    setState(() {
      _user = widget.user;
      _tabController = TabController(vsync: this, length: 4);
    });
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
    return Scaffold(
        appBar: AppBar(),
        body: ListView(
          children: <Widget>[
            _bio(),
          ],
        ));
  }
}
