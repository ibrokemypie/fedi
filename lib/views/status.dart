import 'package:flutter/material.dart';
import 'package:fedi/definitions/status.dart';
import 'package:fedi/api/favourite.dart';
import 'package:fedi/api/renote.dart';
import 'package:fedi/api/unfavourite.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/views/post.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StatusBuilder extends StatefulWidget {
  final Instance instance;
  final String authCode;
  final Status status;

  StatusBuilder(this.instance, this.authCode, this.status);
  @override
  StatusBuilderState createState() => new StatusBuilderState();
}

class StatusBuilderState extends State<StatusBuilder> {
  Color favouriteColour = Colors.white;

  void _toggleFavourite() async {
    bool success;
    if (widget.status.favourited != true) {
      success =
          favouritePost(widget.instance, widget.authCode, widget.status.id);
      if (success) {
        setState(() {
          widget.status.favourited = true;
          widget.status.favCount += 1;
        });
      }
    } else {
      success =
          unFavouritePost(widget.instance, widget.authCode, widget.status.id);
      if (success) {
        setState(() {
          widget.status.favourited = false;
          widget.status.favCount -= 1;
        });
      }
    }
  }

  void _renote() async {
    String postId;
    if (widget.status.renote != null) {
      postId = widget.status.renote.id;
    } else {
      postId = widget.status.id;
    }
    bool success = await renotePost(widget.instance, widget.authCode, postId);
    if (success) {
      setState(() {
        // widget.status.renoted = true;
        widget.status.renoteCount += 1;
      });
    }
  }

  void _reply() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Post(
                  instance: widget.instance,
                  authCode: widget.authCode,
                  replyTo: widget.status.id,
                  preFill: "@" + widget.status.author.acct + " ",
                )));
  }

  @override
  void initState() {
    super.initState();
  }

  _buttonRow() => Row(
        children: <Widget>[
          // Reply
          Row(children: <Widget>[
            IconButton(
              icon: Icon(Icons.reply),
              onPressed: _reply,
            ),
            Text("0"),
          ]),

          // Boost
          Row(children: <Widget>[
            IconButton(
              icon: Icon(Icons.repeat),
              onPressed: _renote,
            ),
            Text(widget.status.renoteCount.toString()),
          ]),

          // Favourite
          Row(children: <Widget>[
            IconButton(
              icon: Icon(Icons.star),
              onPressed: _toggleFavourite,
              color: favouriteColour,
            ),
            Text(widget.status.favCount.toString()),
          ]),
        ],
      );

// TODO: content warning
  _bodyText(String bodyText) => Container(
        padding: const EdgeInsets.only(bottom: 8.0, right: 32.0),
        child: Text(bodyText),
      );

// TODO: sensitive media
  _files(Widget files) => Container(
        padding: const EdgeInsets.only(bottom: 8.0, right: 32.0),
        child: files,
      );

  _accountName(String name) => Text(name);

  _nickName(String nick) => Container(
        padding: const EdgeInsets.only(right: 8.0),
        child: Text(
          nick,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  _visibilityIcon() => Container(
      padding: const EdgeInsets.only(right: 16.0),
      child: Icon(visIcon(widget.status.visibility), size: 16.0));

  _avatar(String avatarUrl) => Container(
        alignment: FractionalOffset.topCenter,
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8),
        child: CircleAvatar(
          backgroundImage: new CachedNetworkImageProvider(avatarUrl),
        ),
      );

  _authorRow(String nickName, String accountName, Widget trailing) => Container(
        padding: const EdgeInsets.only(bottom: 8.0, top: 8),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _nickName(nickName),
                    _accountName(accountName),
                  ]),
              trailing,
            ]),
      );

  _divider() => Divider(
        height: 4,
      );

  _renotedBy() => Expanded(
          child: Row(
        children: <Widget>[
          Icon(Icons.repeat),
          Text("renoted by " + widget.status.author.nickname),
        ],
      ));

  _renoteRow() => Material(
        elevation: 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          color: Colors.red,
          child: Row(
            children: <Widget>[
              Container(
                alignment: FractionalOffset.topCenter,
                padding: const EdgeInsets.only(left: 16.0, right: 4),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: new CachedNetworkImageProvider(
                      widget.status.author.avatarUrl),
                ),
              ),
              _renotedBy(),
              _visibilityIcon()
            ],
          ),
        ),
      );

  _statusTile() => <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _avatar(widget.status.author.avatarUrl),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _authorRow(widget.status.author.nickname,
                    widget.status.author.acct, _visibilityIcon()),
                _bodyText(widget.status.body),
                _files(widget.status.statusFiles()),
                _buttonRow(),
              ],
            )),
          ],
        ),
        _divider(),
      ];

  _renoteTile() => <Widget>[
        _renoteRow(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _avatar(widget.status.renote.author.avatarUrl),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _authorRow(widget.status.renote.author.nickname,
                    widget.status.renote.author.acct, Container()),
                _bodyText(widget.status.renote.body),
                _files(widget.status.renote.statusFiles()),
                _buttonRow(),
              ],
            )),
          ],
        ),
        _divider(),
      ];

  @override
  Widget build(BuildContext context) {
    setState(() {
      if (widget.status.favourited || widget.status.myReaction != null) {
        favouriteColour = Colors.yellow;
      } else {
        favouriteColour = Colors.white;
      }
    });

    if (widget.status.renote != null) {
      return Container(child: Column(children: _renoteTile()));
    } else {
      return Container(child: Column(children: _statusTile()));
    }
  }
}
