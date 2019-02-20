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
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

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
  Color _favouriteColour = Colors.white;
  bool _contentWarningToggled = true;
  Widget _contentWarningView = Container();
  Instance _instance;
  Item _item;
  bool _isRenote = false;
  bool _isReply = false;
  bool _isNotification = false;
  Item _note;
  List<PopupMenuEntry<String>> _menuButtonItems = [
    const PopupMenuItem<String>(
      value: "details",
      child: Text('Context'),
    ),
    const PopupMenuItem<String>(
      value: "copy",
      child: Text('Copy contents'),
    ),
    const PopupMenuItem<String>(
      value: "openLocal",
      child: Text('Open in browser'),
    ),
    const PopupMenuItem<String>(
      value: "openRemote",
      child: Text('Open remote URL in browser'),
    ),
  ];

  void _toggleFavouriteAction() async {
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

  void _renoteAction() async {
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

  void _replyAction() async {
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

  void _showContextAction() {
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

  void _remoteButtonAction() async {
    print(_note.remoteUrl);
    if (await canLaunch(_note.remoteUrl)) {
      await launch(_note.remoteUrl, enableJavaScript: true);
    } else {
      throw 'Could not launch $_note.url';
    }
  }

  void _localButtonAction() async {
    print(_note.localUrl);
    if (await canLaunch(_note.localUrl)) {
      await launch(_note.localUrl, enableJavaScript: true);
    } else {
      throw 'Could not launch $_note.url';
    }
  }

  void _deleteButtonAction() async {
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

  void _copyButtonAction() async {
    Clipboard.setData(new ClipboardData(text: _note.body));
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text("Contents copied to clipboard")));
  }

  void _moreButtonAction(String action) {
    switch (action) {
      case "details":
        _showContextAction();
        break;
      case "delete":
        _deleteButtonAction();
        break;
      case "openRemote":
        _remoteButtonAction();
        break;
      case "openLocal":
        _localButtonAction();
        break;
      case "copy":
        _copyButtonAction();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
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
        } else if (_item.replyId != null) {
          _isReply = true;
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

  _showUserPage(String targetUserId) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserProfile(
                  instance: _instance,
                  userId: targetUserId,
                  currentUser: widget.currentUser,
                  authCode: widget.authCode,
                )));
  }

  _renoteReplyRow() {
    String destinationId = _note.replyId ?? _note.id;

    Widget avatar;
    avatar = GestureDetector(
      child: CircleAvatar(
        radius: 16,
        backgroundImage: new CachedNetworkImageProvider(_item.author.avatarUrl),
      ),
      onTap: () => _showUserPage(_item.author.id),
    );
    // }

    Widget textRow;
    if (_isReply) {
      textRow = Expanded(
          child: Row(
        children: <Widget>[
          Icon(Icons.reply),
          Text("replied to a status"),
        ],
      ));
    } else {
      textRow = Expanded(
          child: Row(
        children: <Widget>[
          Icon(Icons.repeat),
          Text("renoted by " + _item.author.nickname),
        ],
      ));
    }

    return GestureDetector(
        onTap: _showContextAction,
        child: Material(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: Colors.red,
            child: Row(
              children: <Widget>[
                Container(
                    alignment: FractionalOffset.topCenter,
                    padding: const EdgeInsets.only(left: 16.0, right: 4),
                    child: avatar),
                textRow,
                VisibilityIcon(_note.visibility)
              ],
            ),
          ),
        ));
  }

  _date() => Text(timeago.format(DateTime.parse(_item.date)) + " ");

  _statusTile() => <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Avatar(_note.author, _showUserPage),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AuthorRow(
                    _note.author.nickname,
                    _note.author.acct,
                    Row(children: <Widget>[
                      _date(),
                      VisibilityIcon(_note.visibility)
                    ])),
                Body(_note, _instance, _contentWarningToggled,
                    _contentWarningView),
                Files(StatusFiles(widget.isContext, _showContextAction, _note)),
                ButtonRow(
                    _note,
                    _replyAction,
                    _renoteAction,
                    _toggleFavouriteAction,
                    _favouriteColour,
                    _moreButtonAction,
                    _menuButtonItems),
              ],
            )),
          ],
        ),
        ItemDivider(),
      ];

  _renoteReplyTile() => <Widget>[
        _renoteReplyRow(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Avatar(_note.author, _showUserPage),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AuthorRow(_note.author.nickname, _note.author.acct,
                    Row(children: <Widget>[_date()])),
                Body(_note, _instance, _contentWarningToggled,
                    _contentWarningView),
                Files(StatusFiles(widget.isContext, _showContextAction, _note)),
                ButtonRow(
                    _note,
                    _replyAction,
                    _renoteAction,
                    _toggleFavouriteAction,
                    _favouriteColour,
                    _moreButtonAction,
                    _menuButtonItems),
              ],
            )),
          ],
        ),
        ItemDivider(),
      ];

  _notificationTile() {
    List<Widget> Content = <Widget>[
      NotificationRow(_item, _showUserPage),
    ];
    if (_item.notificationType != "follow") {
      Content.addAll([
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Avatar(_note.author, _showUserPage),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AuthorRow(
                    _note.author.nickname,
                    _note.author.acct,
                    Row(children: <Widget>[
                      _date(),
                      VisibilityIcon(_note.visibility)
                    ])),
                Body(_note, _instance, _contentWarningToggled,
                    _contentWarningView),
                Files(StatusFiles(widget.isContext, _showContextAction, _note)),
                ButtonRow(
                    _note,
                    _replyAction,
                    _renoteAction,
                    _toggleFavouriteAction,
                    _favouriteColour,
                    _moreButtonAction,
                    _menuButtonItems),
              ],
            )),
          ],
        ),
        ItemDivider(),
      ]);
    } else {
      Content.addAll([
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Avatar(_note.author, _showUserPage),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AuthorRow(
                    _note.author.nickname,
                    _note.author.acct,
                    Row(children: <Widget>[
                      _date(),
                      VisibilityIcon(_note.visibility)
                    ])),
              ],
            )),
          ],
        ),
        ItemDivider(),
      ]);
    }
    return Content;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if (_note.favourited == true || (_note.myReaction != null)) {
        _favouriteColour = Colors.yellow;
      } else {
        _favouriteColour = Colors.white;
      }
    });

    if (_isNotification) {
      return Container(child: Column(children: _notificationTile()));
    } else if (_isRenote || _isReply && !widget.isContext) {
      return Container(child: Column(children: _renoteReplyTile()));
    } else {
      return Container(child: Column(children: _statusTile()));
    }
  }
}

class NotificationRow extends StatelessWidget {
  final Item item;
  final Function showUserPage;

  NotificationRow(this.item, this.showUserPage);

  @override
  Widget build(BuildContext context) {
    return Material(
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
                      new CachedNetworkImageProvider(item.author.avatarUrl),
                ),
                onTap: () => showUserPage(item.author.id),
              ),
            ),
            notificationTypeIcon(item.notificationType),
            NotificationText(item),
          ],
        ),
      ),
    );
  }
}

class NotificationText extends StatelessWidget {
  final Item item;

  NotificationText(this.item);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
          item.author.nickname + notificationTypeString(item.notificationType)),
    );
  }
}

class ItemDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 4,
    );
  }
}

class ButtonRow extends StatelessWidget {
  final Item note;

  final Function replyAction;
  final Function renoteAction;
  final Function favouriteAction;
  final Function menuAction;

  final Color favouriteColour;

  final List<PopupMenuEntry<String>> menuItems;

  ButtonRow(
      this.note,
      this.replyAction,
      this.renoteAction,
      this.favouriteAction,
      this.favouriteColour,
      this.menuAction,
      this.menuItems);

  @override
  Widget build(BuildContext context) {
    return Row(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(children: <Widget>[
          // Reply
          Row(children: <Widget>[
            IconButton(
              icon: Icon(Icons.reply),
              onPressed: replyAction,
            ),
            Text(note.replyCount.toString()),
          ]),

          // Boost
          Row(children: <Widget>[
            IconButton(
              icon: Icon(Icons.repeat),
              onPressed: renoteAction,
            ),
            Text(note.renoteCount.toString()),
          ]),

          // Favourite
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.star),
                onPressed: favouriteAction,
                color: favouriteColour,
              ),
              Text(note.favCount.toString()),
            ],
          ),
        ]),
        PopupMenuButton(
          icon: Icon(Icons.more_horiz),
          itemBuilder: (BuildContext context) => menuItems,
          onSelected: menuAction,
        )
      ],
    );
  }
}

class Nickname extends StatelessWidget {
  final String nickname;

  Nickname(this.nickname);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 8.0),
      child: Text(
        nickname,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class VisibilityIcon extends StatelessWidget {
  final String visibility;
  VisibilityIcon(this.visibility);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(visIcon(visibility), size: 16.0));
  }
}

class Avatar extends StatelessWidget {
  final User user;
  final Function showUserPage;

  Avatar(this.user, this.showUserPage);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: FractionalOffset.topCenter,
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8),
      child: GestureDetector(
        child: CircleAvatar(
          backgroundImage: new CachedNetworkImageProvider(user.avatarUrl),
        ),
        onTap: () => showUserPage(user.id),
      ),
    );
  }
}

class Body extends StatelessWidget {
  final Item note;
  final Instance instance;
  final bool contentToggled;
  final Widget contentWarningView;

  Body(this.note, this.instance, this.contentToggled, this.contentWarningView);

  @override
  Widget build(BuildContext context) {
    var _bodyTextWidget;

    if (contentToggled == true) {
      _bodyTextWidget = PostBody(instance, note);
    } else {
      _bodyTextWidget = Container();
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 8.0, right: 32.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[contentWarningView, _bodyTextWidget]),
    );
  }
}

class Files extends StatelessWidget {
  final Widget files;
  Files(this.files);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8.0, right: 32.0),
      child: files,
    );
  }
}

class AuthorRow extends StatelessWidget {
  final String nickName;
  final String accountName;
  final Widget trailing;

  AuthorRow(this.nickName, this.accountName, this.trailing);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(child: Nickname(nickName)),
                  trailing,
                ]),
            Text(accountName),
          ]),
    );
  }
}
