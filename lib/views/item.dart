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
  bool _isContext = false;
  Item _note;
  Key _key;
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

  void _toggleCw() {
    setState(() {
      _contentWarningToggled = !_contentWarningToggled;
    });
  }

  _showUserPageAction(String targetUserId) async {
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

  @override
  void initState() {
    super.initState();
    setState(() {
      _instance = widget.instance;
      _item = widget.item;
      _isContext = widget.isContext;
      _note = _item;

      _key = Key(_item.id + _note.id);

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
          _contentWarningView = ContentWarning(_note, true, _toggleCw, _key);
          _contentWarningToggled = false;
        } else {
          _contentWarningView = ContentWarning(_note, false, _toggleCw, _key);
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
      return NotificationWidget(
          _note,
          _item,
          _instance,
          _showUserPageAction,
          _showContextAction,
          _replyAction,
          _renoteAction,
          _toggleFavouriteAction,
          _moreButtonAction,
          _isContext,
          _contentWarningToggled,
          _contentWarningView,
          _menuButtonItems,
          _favouriteColour,
          _key);
    } else if (_isRenote || _isReply && !widget.isContext) {
      return RenoteReplyWidget(
          _note,
          _item,
          _instance,
          _showUserPageAction,
          _showContextAction,
          _replyAction,
          _renoteAction,
          _toggleFavouriteAction,
          _moreButtonAction,
          _isReply,
          _isContext,
          _contentWarningToggled,
          _contentWarningView,
          _menuButtonItems,
          _favouriteColour,
          _key);
    } else {
      return StatusWidget(
          _note,
          _item,
          _instance,
          _showUserPageAction,
          _showContextAction,
          _replyAction,
          _renoteAction,
          _toggleFavouriteAction,
          _moreButtonAction,
          _isContext,
          _contentWarningToggled,
          _contentWarningView,
          _menuButtonItems,
          _favouriteColour,
          _key);
    }
  }
}

class StatusWidget extends StatelessWidget {
  final Item note;
  final Item item;
  final Instance instance;
  final Function showUserPageAction;
  final Function showContextAction;
  final Function replyAction;
  final Function renoteAction;
  final Function toggleFavouriteAction;
  final Function moreButtonAction;
  final bool isContext;
  final bool contentWarningToggled;
  final Widget contentWarningView;
  final List<PopupMenuEntry<String>> menuButtonItems;
  final Color favouriteColour;
  final Key key;

  StatusWidget(
      this.note,
      this.item,
      this.instance,
      this.showUserPageAction,
      this.showContextAction,
      this.replyAction,
      this.renoteAction,
      this.toggleFavouriteAction,
      this.moreButtonAction,
      this.isContext,
      this.contentWarningToggled,
      this.contentWarningView,
      this.menuButtonItems,
      this.favouriteColour,
      this.key);

  _statusTile() => <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Avatar(note.author, showUserPageAction, ValueKey("avatar")),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AuthorRow(
                      note.author.nickname,
                      note.author.acct,
                      Row(children: <Widget>[
                        Date(note.date, ValueKey("date")),
                        VisibilityIcon(
                            note.visibility, ValueKey("visibilityicon"))
                      ]),
                      ValueKey("authorrow")),
                  Body(note, instance, contentWarningToggled,
                      contentWarningView, ValueKey("body")),
                  Files(StatusFiles(isContext, showContextAction, note),
                      ValueKey("files")),
                  ButtonRow(
                      note,
                      replyAction,
                      renoteAction,
                      toggleFavouriteAction,
                      favouriteColour,
                      moreButtonAction,
                      menuButtonItems,
                      ValueKey("buttons")),
                ],
              ),
              key: ValueKey("content"),
            ),
          ],
        ),
        ItemDivider(),
      ];

  @override
  Widget build(BuildContext context) {
    return Container(child: Column(children: _statusTile()));
  }
}

class RenoteReplyWidget extends StatelessWidget {
  final Item note;
  final Item item;
  final Instance instance;
  final Function showUserPageAction;
  final Function showContextAction;
  final Function replyAction;
  final Function renoteAction;
  final Function toggleFavouriteAction;
  final Function moreButtonAction;
  final bool isReply;
  final bool isContext;
  final bool contentWarningToggled;
  final Widget contentWarningView;
  final List<PopupMenuEntry<String>> menuButtonItems;
  final Color favouriteColour;
  final Key key;

  RenoteReplyWidget(
      this.note,
      this.item,
      this.instance,
      this.showUserPageAction,
      this.showContextAction,
      this.replyAction,
      this.renoteAction,
      this.toggleFavouriteAction,
      this.moreButtonAction,
      this.isReply,
      this.isContext,
      this.contentWarningToggled,
      this.contentWarningView,
      this.menuButtonItems,
      this.favouriteColour,
      this.key);

  _renoteReplyTile() => <Widget>[
        ReplyRenoteRow(
            note, item, isReply, showUserPageAction, showContextAction, key),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Avatar(note.author, showUserPageAction, ValueKey("avatar")),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AuthorRow(
                      note.author.nickname,
                      note.author.acct,
                      Row(children: <Widget>[
                        Date(note.date, ValueKey("date"))
                      ]),
                      ValueKey("authorrow")),
                  Body(note, instance, contentWarningToggled,
                      contentWarningView, ValueKey("body")),
                  Files(StatusFiles(isContext, showContextAction, note),
                      ValueKey("files")),
                  ButtonRow(
                      note,
                      replyAction,
                      renoteAction,
                      toggleFavouriteAction,
                      favouriteColour,
                      moreButtonAction,
                      menuButtonItems,
                      ValueKey("buttons")),
                ],
              ),
              key: ValueKey("contents"),
            ),
          ],
        ),
        ItemDivider(),
      ];

  @override
  Widget build(BuildContext context) {
    return Container(child: Column(children: _renoteReplyTile()));
  }
}

class NotificationWidget extends StatelessWidget {
  final Item note;
  final Item item;
  final Instance instance;
  final Function showUserPageAction;
  final Function showContextAction;
  final Function replyAction;
  final Function renoteAction;
  final Function toggleFavouriteAction;
  final Function moreButtonAction;
  final bool isContext;
  final bool contentWarningToggled;
  final Widget contentWarningView;
  final List<PopupMenuEntry<String>> menuButtonItems;
  final Color favouriteColour;
  final Key key;

  NotificationWidget(
      this.note,
      this.item,
      this.instance,
      this.showUserPageAction,
      this.showContextAction,
      this.replyAction,
      this.renoteAction,
      this.toggleFavouriteAction,
      this.moreButtonAction,
      this.isContext,
      this.contentWarningToggled,
      this.contentWarningView,
      this.menuButtonItems,
      this.favouriteColour,
      this.key);

  notificationTile() {
    List<Widget> content = <Widget>[
      NotificationRow(item, showUserPageAction, key),
    ];
    if (item.notificationType != "follow") {
      content.addAll([
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Avatar(note.author, showUserPageAction, ValueKey("avatar")),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AuthorRow(
                      note.author.nickname,
                      note.author.acct,
                      Row(children: <Widget>[
                        Date(note.date, ValueKey("date")),
                        VisibilityIcon(
                            note.visibility, ValueKey("visibilityicon"))
                      ]),
                      ValueKey("authorrow")),
                  Body(note, instance, contentWarningToggled,
                      contentWarningView, ValueKey("body")),
                  Files(StatusFiles(isContext, showContextAction, note),
                      ValueKey("files")),
                  ButtonRow(
                      note,
                      replyAction,
                      renoteAction,
                      toggleFavouriteAction,
                      favouriteColour,
                      moreButtonAction,
                      menuButtonItems,
                      ValueKey("buttons")),
                ],
              ),
              key: ValueKey("contents"),
            ),
          ],
        ),
        ItemDivider(),
      ]);
    } else {
      content.addAll([
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Avatar(note.author, showUserPageAction, ValueKey("avatar")),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AuthorRow(
                      note.author.nickname,
                      note.author.acct,
                      Row(children: <Widget>[
                        Date(note.date, ValueKey("date")),
                        VisibilityIcon(
                            note.visibility, ValueKey("visibilityicon"))
                      ]),
                      ValueKey("authorrow")),
                ],
              ),
              key: ValueKey("contents"),
            ),
          ],
        ),
        ItemDivider(),
      ]);
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: Column(children: notificationTile()));
  }
}

class NotificationRow extends StatelessWidget {
  final Item item;
  final Function showUserPage;
  final Key key;

  NotificationRow(this.item, this.showUserPage, this.key);

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
              key: ValueKey("avatar"),
            ),
            notificationTypeIcon(item.notificationType),
            NotificationText(item, key),
          ],
        ),
      ),
    );
  }
}

class NotificationText extends StatelessWidget {
  final Item item;
  final Key key;

  NotificationText(this.item, this.key);

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

  final Key key;

  ButtonRow(
      this.note,
      this.replyAction,
      this.renoteAction,
      this.favouriteAction,
      this.favouriteColour,
      this.menuAction,
      this.menuItems,
      this.key);

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
          ], key: ValueKey("replybutton")),

          // Boost
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.repeat),
                onPressed: renoteAction,
              ),
              Text(note.renoteCount.toString()),
            ],
            key: ValueKey("boostbutton"),
          ),

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
      key: ValueKey("favouritebutton"),
    );
  }
}

class Nickname extends StatelessWidget {
  final String nickname;
  final Key key;

  Nickname(this.nickname, this.key);

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
      key: key,
    );
  }
}

class VisibilityIcon extends StatelessWidget {
  final String visibility;
  final Key key;

  VisibilityIcon(this.visibility, this.key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 16.0),
      child: Icon(visIcon(visibility), size: 16.0),
      key: key,
    );
  }
}

class Avatar extends StatelessWidget {
  final User user;
  final Function showUserPage;
  final Key key;

  Avatar(this.user, this.showUserPage, this.key);

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
      key: key,
    );
  }
}

class Body extends StatelessWidget {
  final Item note;
  final Instance instance;
  final bool contentToggled;
  final Widget contentWarningView;
  final Key key;

  Body(this.note, this.instance, this.contentToggled, this.contentWarningView,
      this.key);

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
      key: key,
    );
  }
}

class Files extends StatelessWidget {
  final Widget files;
  final Key key;

  Files(this.files, this.key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8.0, right: 32.0),
      child: files,
      key: key,
    );
  }
}

class AuthorRow extends StatelessWidget {
  final String nickName;
  final String accountName;
  final Widget trailing;
  final Key key;

  AuthorRow(this.nickName, this.accountName, this.trailing, this.key);

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
                  Flexible(child: Nickname(nickName, key)),
                  trailing,
                ]),
            Text(accountName),
          ]),
      key: key,
    );
  }
}

class ContentWarning extends StatelessWidget {
  final Item note;
  final bool hasButton;
  final Function toggleCw;
  final Key key;

  ContentWarning(this.note, this.hasButton, this.toggleCw, this.key);

  @override
  Widget build(BuildContext context) {
    Widget _contentWarningToggle = Container();
    if (hasButton) {
      _contentWarningToggle = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RaisedButton(
              child: Text("Toggle content"),
              color: Colors.red,
              onPressed: toggleCw,
            ),
            Text(note.body.length.toString())
          ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(note.contentWarning),
        _contentWarningToggle,
        Divider(
          height: 2,
        ),
      ],
      key: key,
    );
  }
}

class Date extends StatelessWidget {
  final String date;
  final Key key;

  Date(this.date, this.key);

  @override
  Widget build(BuildContext context) {
    return Text(
      timeago.format(DateTime.parse(date)) + " ",
      key: key,
    );
  }
}

class ReplyRenoteRow extends StatelessWidget {
  final Item note;
  final Item item;
  final bool isReply;
  final Function showUserPageAction;
  final Function showContextAction;
  final Key key;

  ReplyRenoteRow(this.note, this.item, this.isReply, this.showUserPageAction,
      this.showContextAction, this.key);

  @override
  Widget build(BuildContext context) {
    String destinationId = note.replyId ?? note.id;

    Widget avatar;
    avatar = GestureDetector(
      child: CircleAvatar(
        radius: 16,
        backgroundImage: new CachedNetworkImageProvider(item.author.avatarUrl),
      ),
      onTap: () => showUserPageAction(item.author.id),
      key: key,
    );
    // }

    Widget textRow;
    if (isReply) {
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
          Text("renoted by " + item.author.nickname),
        ],
      ));
    }

    return GestureDetector(
      onTap: showContextAction,
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
              VisibilityIcon(note.visibility, key)
            ],
          ),
        ),
      ),
      key: key,
    );
  }
}
