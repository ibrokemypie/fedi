import 'package:flutter/material.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/api/favourite.dart';
import 'package:fedi/api/renote.dart';
import 'package:fedi/api/unfavourite.dart';
import 'package:fedi/api/getuser.dart';
import 'package:fedi/api/delete.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/definitions/mention.dart';
import 'package:fedi/definitions/user.dart';
import 'package:fedi/views/post.dart';
import 'package:fedi/views/statusfiles.dart';
import 'package:fedi/views/context.dart';
import 'package:fedi/views/statusbody.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:fedi/views/user.dart';

class ItemBuilder extends StatefulWidget {
  final Instance instance;
  final String authCode;
  final Item item;
  final bool isContext;
  final Key key;
  final User currentUser;

  ItemBuilder(
      {this.instance,
      this.authCode,
      this.item,
      this.isContext,
      this.key,
      this.currentUser});
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
  List<PopupMenuEntry<String>> _menuButtonItems = [
    const PopupMenuItem<String>(
      value: "details",
      child: Text('Details'),
    ),
  ];
  bool _firstbuild;

  void _toggleFavourite() async {
    if (_note.favourited != true) {
      try {
        await favouritePost(_instance, widget.authCode, _note.id);
        setState(() {
          _note.favourited = true;
          _note.favCount += 1;
        });
      } catch (e) {
        print(e);
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      }
    } else {
      try {
        await unFavouritePost(_instance, widget.authCode, _note.id);
        setState(() {
          _note.favourited = false;
          _note.favCount -= 1;
        });
      } catch (e) {
        print(e);
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      }
    }
  }

  void _renote() async {
    try {
      await renotePost(_instance, widget.authCode, _note.id);
      setState(() {
        // widget.status.renoted = true;
        _note.renoteCount += 1;
      });
    } catch (e) {
      print(e);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  void _reply() async {
    String prefill = "@" + _note.author.acct + " ";
    for (Mention mentionObject in _note.mentions) {
      if (mentionObject.id != widget.currentUser.id) {
        if (mentionObject.acct != null) {
          prefill = prefill + "@" + mentionObject.acct + " ";
        } else {
          User mentionedUser = await getUserFromId(_instance, mentionObject.id);
          prefill = prefill + "@" + mentionedUser.acct + " ";
        }
      }
    }
    print(prefill);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Post(
                  instance: _instance,
                  authCode: widget.authCode,
                  replyTo: _note.id,
                  preFillBody: prefill,
                  preFillContentWarning: _note.contentWarning,
                  visibility: _note.visibility,
                )));
  }

  void _showContext() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => StatusContext(
                  authCode: widget.authCode,
                  instance: _instance,
                  statusId: _note.id,
                  currentUser: widget.currentUser,
                  originalStatus: _note,
                )));
  }

  void _deleteButton() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete note?"),
            content: Text("Thiis cannot be undone."),
            actions: <Widget>[
              new FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: Text("Delete"),
                onPressed: () {
                  deletePost(_instance, widget.authCode, _note.id);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void _moreButtonAction(String action) {
    switch (action) {
      case "details":
        _showContext();
        break;
      case "delete":
        _deleteButton();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _firstbuild = true;

      _instance = widget.instance;
      _item = widget.item;
      _note = _item;

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

      if (_note.contentWarning != null && _note.contentWarning != "") {
        if (_note.body != "") {
          _contentWarningView = _contentWarning(true);
          _contentWarningToggled = false;
        } else {
          _contentWarningView = _contentWarning(false);
        }
      }
      if (_note.author.id == widget.currentUser.id) {
        _menuButtonItems.add(
          const PopupMenuItem<String>(
            value: "delete",
            child: Text('Delete'),
          ),
        );
      }
    });
  }

  _buttonRow() => Row(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(children: <Widget>[
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
            Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.star),
                  onPressed: _toggleFavourite,
                  color: favouriteColour,
                ),
                Text(_note.favCount.toString()),
              ],
            ),
          ]),
          PopupMenuButton(
            icon: Icon(Icons.more_horiz),
            itemBuilder: (BuildContext context) => _menuButtonItems,
            onSelected: _moreButtonAction,
          )
        ],
      );

  _contentWarning(bool hasButton) {
    Widget _contentWarningToggle = Container();
    if (hasButton) {
      _contentWarningToggle = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RaisedButton(
                child: Text("Toggle content"),
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    _contentWarningToggled = !_contentWarningToggled;
                  });
                }),
            Text(_note.body.length.toString())
          ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(_note.contentWarning),
        _contentWarningToggle,
        Divider(
          height: 2,
        ),
      ],
    );
  }

  _body(String bodyText) {
    setState(() {
      if (_contentWarningToggled == true) {
        _bodyTextWidget = PostBody(_instance, _note);
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

  _files(Widget files) => Container(
        padding: const EdgeInsets.only(bottom: 8.0, right: 32.0),
        child: files,
      );

  _accountName(String name) => Text(name);

  _nickName(String nick) => Container(
        padding: const EdgeInsets.only(right: 8.0),
        child: Text(
          nick,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  _visibilityIcon() => Container(
      padding: const EdgeInsets.only(right: 16.0),
      child: Icon(visIcon(_note.visibility), size: 16.0));

  _avatar(User user) => Container(
        alignment: FractionalOffset.topCenter,
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8),
        child: GestureDetector(
          child: CircleAvatar(
            backgroundImage: new CachedNetworkImageProvider(user.avatarUrl),
          ),
          onTap: () => _showUserPage(user.id),
        ),
      );

  _showUserPage(String targetUserId) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserProfile(
                  instance: _instance,
                  userId: targetUserId,
                )));
  }

  _authorRow(String nickName, String accountName, Widget trailing) => Container(
        padding: const EdgeInsets.only(bottom: 8.0, top: 8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(child: _nickName(nickName)),
                    trailing,
                  ]),
              _accountName(accountName),
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
                child: GestureDetector(
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage:
                        new CachedNetworkImageProvider(_item.author.avatarUrl),
                  ),
                  onTap: () => _showUserPage(_item.author.id),
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
                child: GestureDetector(
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage:
                        new CachedNetworkImageProvider(_item.author.avatarUrl),
                  ),
                  onTap: () => _showUserPage(_item.author.id),
                ),
              ),
              notificationTypeIcon(_item.notificationType),
              _notificationText(),
            ],
          ),
        ),
      );

  _date() => Text(timeago.format(DateTime.parse(_item.date)) + " ");

  _statusTile() => <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _avatar(_note.author),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _authorRow(_note.author.nickname, _note.author.acct,
                    Row(children: <Widget>[_date(), _visibilityIcon()])),
                _body(_note.body),
                _files(statusFiles(widget.isContext, _showContext, _note)),
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
            _avatar(_note.author),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _authorRow(_note.author.nickname, _note.author.acct,
                    Row(children: <Widget>[_date()])),
                _body(_note.body),
                _files(statusFiles(widget.isContext, _showContext, _note)),
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
            _avatar(_note.author),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _authorRow(_note.author.nickname, _note.author.acct,
                    Row(children: <Widget>[_date(), _visibilityIcon()])),
                _body(_note.body),
                _files(statusFiles(widget.isContext, _showContext, _note)),
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
            _avatar(_note.author),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _authorRow(_note.author.nickname, _note.author.acct,
                    Row(children: <Widget>[_date(), _visibilityIcon()])),
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
      if (_note.favourited == true || (_note.myReaction != null)) {
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
