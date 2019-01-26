import 'package:flutter/material.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/api/favourite.dart';
import 'package:fedi/api/renote.dart';
import 'package:fedi/api/unfavourite.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/views/post.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ItemBuilder extends StatefulWidget {
  final Instance instance;
  final String authCode;
  final Item item;

  ItemBuilder(this.instance, this.authCode, this.item);
  @override
  ItemBuilderState createState() => new ItemBuilderState();
}

class ItemBuilderState extends State<ItemBuilder> {
  Color favouriteColour = Colors.white;

  void _toggleFavourite() async {
    bool success;
    if (widget.item.favourited != true) {
      success = favouritePost(widget.instance, widget.authCode, widget.item.id);
      if (success) {
        setState(() {
          widget.item.favourited = true;
          widget.item.favCount += 1;
        });
      }
    } else {
      success =
          unFavouritePost(widget.instance, widget.authCode, widget.item.id);
      if (success) {
        setState(() {
          widget.item.favourited = false;
          widget.item.favCount -= 1;
        });
      }
    }
  }

  void _renote() async {
    String postId;
    if (widget.item.renote != null) {
      postId = widget.item.renote.id;
    } else {
      postId = widget.item.id;
    }
    bool success = await renotePost(widget.instance, widget.authCode, postId);
    if (success) {
      setState(() {
        // widget.status.renoted = true;
        widget.item.renoteCount += 1;
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
                  replyTo: widget.item.id,
                  preFill: "@" + widget.item.author.acct + " ",
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
            Text(widget.item.renoteCount.toString()),
          ]),

          // Favourite
          Row(children: <Widget>[
            IconButton(
              icon: Icon(Icons.star),
              onPressed: _toggleFavourite,
              color: favouriteColour,
            ),
            Text(widget.item.favCount.toString()),
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
      child: Icon(visIcon(widget.item.visibility), size: 16.0));

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
          Text("renoted by " + widget.item.author.nickname),
        ],
      ));

_notificationText() =>               Expanded(
                child: Text(widget.item.author.nickname +
                    notificationTypeString(
                        widget.item.notificationType)),
              );

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
                      widget.item.author.avatarUrl),
                ),
              ),
              _renotedBy(),
              _visibilityIcon()
            ],
          ),
        ),
      );

  _notificationRow() => Material(
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
                      widget.item.author.avatarUrl),
                ),
              ),
              notificationTypeIcon(widget.item.notificationType),
              _notificationText(),
            ],
          ),
        ),
      );

  _statusTile() => <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _avatar(widget.item.author.avatarUrl),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _authorRow(widget.item.author.nickname, widget.item.author.acct,
                    _visibilityIcon()),
                _bodyText(widget.item.body),
                _files(widget.item.statusFiles()),
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
            _avatar(widget.item.renote.author.avatarUrl),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _authorRow(widget.item.renote.author.nickname,
                    widget.item.renote.author.acct, Container()),
                _bodyText(widget.item.renote.body),
                _files(widget.item.renote.statusFiles()),
                _buttonRow(),
              ],
            )),
          ],
        ),
        _divider(),
      ];

  _notificationTile() => <Widget>[
        _notificationRow(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _avatar(widget.item.notificationNote.author.avatarUrl),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _authorRow(widget.item.notificationNote.author.nickname,
                    widget.item.notificationNote.author.acct, _visibilityIcon()),
                _bodyText(widget.item.notificationNote.body),
                _files(widget.item.notificationNote.statusFiles()),
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
      if (widget.item.favourited || widget.item.myReaction != null) {
        favouriteColour = Colors.yellow;
      } else {
        favouriteColour = Colors.white;
      }
    });

    if (widget.item.notificationType != null) {
      return Container(child: Column(children: _notificationTile()));
    } else if (widget.item.renote != null) {
      return Container(child: Column(children: _renoteTile()));
    } else {
      return Container(child: Column(children: _statusTile()));
    }
  }
}
