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
  bool _contentWarningToggled = true;
  Widget _contentWarningView = Container();
  Widget _bodyTextWidget = Container();
  Instance _instance;
  Item _item;
  bool _isRenote = false;
  bool _isNotification = false;
  Item _note;

  void _toggleFavourite() async {
    bool success;
    if (_note.favourited != true) {
      success = favouritePost(_instance, widget.authCode, _note.id);
      if (success) {
        setState(() {
          _note.favourited = true;
          _note.favCount += 1;
        });
      }
    } else {
      success = unFavouritePost(_instance, widget.authCode, _note.id);
      if (success) {
        setState(() {
          _note.favourited = false;
          _note.favCount -= 1;
        });
      }
    }
  }

  void _renote() async {
    bool success = await renotePost(_instance, widget.authCode, _note.id);
    if (success) {
      setState(() {
        // widget.status.renoted = true;
        _note.renoteCount += 1;
      });
    }
  }

  void _reply() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Post(
                  instance: _instance,
                  authCode: widget.authCode,
                  replyTo: _note.id,
                  preFill: "@" + _note.author.acct + " ",
                )));
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _instance = widget.instance;
      _item = widget.item;
      _note = _item;
      if (_item.contentWarning != null) {
        _contentWarningView = _contentWarning();
        _contentWarningToggled = false;
      }

      if (_item.notificationType != null) {
        _isNotification = true;
        if (_item.notificationNote != null) {
          _note = _item.notificationNote;
          if (_item.notificationNote.renote != null) {
            _isRenote = true;
            _note = _item.notificationNote.renote;
          }
        }
      } else {
        if (_item.renote != null) {
          _isRenote = true;
          _note = _item.renote;
        }
      }
    });
  }

  _buttonRow() => Row(
        children: <Widget>[
          // Reply
          Row(children: <Widget>[
            IconButton(
              icon: Icon(Icons.reply),
              onPressed: _reply,
            ),
            Text(_note.replyCount.toString()),
          ]),

          // Boost
          Row(children: <Widget>[
            IconButton(
              icon: Icon(Icons.repeat),
              onPressed: _renote,
            ),
            Text(_note.renoteCount.toString()),
          ]),

          // Favourite
          Row(children: <Widget>[
            IconButton(
              icon: Icon(Icons.star),
              onPressed: _toggleFavourite,
              color: favouriteColour,
            ),
            Text(_note.favCount.toString()),
          ]),
        ],
      );

  _contentWarning() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
              Text(_note.contentWarning),
              RaisedButton(
                child: Text("Toggle content"),
                color: Colors.red,
                onPressed: () => setState(() {
                      _contentWarningToggled = !_contentWarningToggled;
                    }),
              ),
          Divider(
            height: 2,
          ),
        ],
      );

  _body(String bodyText) {
    setState(() {
      if (_contentWarningToggled == true) {
        _bodyTextWidget = Text(bodyText);
      } else {
        _bodyTextWidget = Container();
      }
    });

    return Container(
      padding: const EdgeInsets.only(bottom: 8.0, right: 32.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[_contentWarningView, _bodyTextWidget]),
    );
  }

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
      child: Icon(visIcon(_note.visibility), size: 16.0));

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
          Text("renoted by " + _item.author.nickname),
        ],
      ));

  _notificationText() => Expanded(
        child: Text(_item.author.nickname +
            notificationTypeString(_item.notificationType)),
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
                  backgroundImage:
                      new CachedNetworkImageProvider(_item.author.avatarUrl),
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
                  backgroundImage:
                      new CachedNetworkImageProvider(_item.author.avatarUrl),
                ),
              ),
              notificationTypeIcon(_item.notificationType),
              _notificationText(),
            ],
          ),
        ),
      );

  _statusTile() => <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _avatar(_note.author.avatarUrl),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _authorRow(_note.author.nickname, _note.author.acct,
                    _visibilityIcon()),
                _body(_note.body),
                _files(_note.statusFiles()),
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
            _avatar(_note.author.avatarUrl),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _authorRow(
                    _note.author.nickname, _note.author.acct, Container()),
                _body(_note.body),
                _files(_note.statusFiles()),
                _buttonRow(),
              ],
            )),
          ],
        ),
        _divider(),
      ];

  _notificationTile() {
    List<Widget> Content = <Widget>[
      _notificationRow(),
    ];
    if (_item.notificationType != "follow") {
      Content.addAll([
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _avatar(_note.author.avatarUrl),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _authorRow(_note.author.nickname, _note.author.acct,
                    _visibilityIcon()),
                _body(_note.body),
                _files(_note.statusFiles()),
                _buttonRow(),
              ],
            )),
          ],
        ),
        _divider(),
      ]);
    } else {
      Content.addAll([
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _avatar(_note.author.avatarUrl),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _authorRow(_note.author.nickname, _note.author.acct,
                    _visibilityIcon()),
              ],
            )),
          ],
        ),
        _divider(),
      ]);
    }
    return Content;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if (_note.favourited || _note.myReaction != null) {
        favouriteColour = Colors.yellow;
      } else {
        favouriteColour = Colors.white;
      }
    });

    if (_isNotification) {
      return Container(child: Column(children: _notificationTile()));
    } else if (_isRenote) {
      return Container(child: Column(children: _renoteTile()));
    } else {
      return Container(child: Column(children: _statusTile()));
    }
  }
}
