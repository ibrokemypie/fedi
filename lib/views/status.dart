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
    bool success;
    success =
        await renotePost(widget.instance, widget.authCode, widget.status.id);
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

  @override
  Widget build(BuildContext context) {
    setState(() {
      if (widget.status.favourited || widget.status.myReaction != null) {
        favouriteColour = Colors.yellow;
      } else {
        favouriteColour = Colors.white;
      }
    });

    Widget statusTile;
    statusTile = Container(
        child: Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Avatar
            Container(
              alignment: FractionalOffset.topCenter,
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8),
              child: CircleAvatar(
                backgroundImage: new CachedNetworkImageProvider(
                    widget.status.author.avatarUrl),
              ),
            ),

            // Content
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Author
                Container(
                  padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Nickname
                              Container(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  widget.status.author.nickname,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // Account name
                              Text(widget.status.author.acct),
                            ]),
                        Container(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Icon(visIcon(widget.status.visibility),
                                size: 16.0))
                      ]),
                ),

                // Body
                Container(
                  padding: const EdgeInsets.only(bottom: 8.0, right: 32.0),
                  child: Text(widget.status.body),
                ),

                Container(
                  padding: const EdgeInsets.only(bottom: 8.0, right: 32.0),
                  child: widget.status.statusFiles(),
                ),

                // Buttons
                Row(
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
                ),
              ],
            )),
          ],
        ),
        Divider(
          height: 4,
        ),
      ],
    ));

    return statusTile;
  }
}
