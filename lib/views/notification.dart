import 'package:flutter/material.dart';
import 'package:fedi/definitions/status.dart';
import 'package:fedi/definitions/notification.dart';
import 'package:fedi/api/favourite.dart';
import 'package:fedi/api/renote.dart';
import 'package:fedi/api/unfavourite.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/views/post.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NotificationBuilder extends StatefulWidget {
  final Instance instance;
  final String authCode;
  final FediNotification notification;

  NotificationBuilder(this.instance, this.authCode, this.notification);
  @override
  NotificationBuilderState createState() => new NotificationBuilderState();
}

class NotificationBuilderState extends State<NotificationBuilder> {
  Color favouriteColour = Colors.white;
  FediNotification notification;

  void _toggleFavourite() async {
    bool success;
    if (widget.notification.note.favourited != true) {
      success = favouritePost(
          widget.instance, widget.authCode, widget.notification.note.id);
      if (success) {
        setState(() {
          widget.notification.note.favourited = true;
          widget.notification.note.favCount += 1;
        });
      }
    } else {
      success = unFavouritePost(
          widget.instance, widget.authCode, widget.notification.note.id);
      if (success) {
        setState(() {
          widget.notification.note.favourited = false;
          widget.notification.note.favCount -= 1;
        });
      }
    }
  }

  void _renote() async {
    bool success;
    success = await renotePost(
        widget.instance, widget.authCode, widget.notification.note.id);
    if (success) {
      setState(() {
        // widget.status.renoted = true;
        widget.notification.note.renoteCount += 1;
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
                  replyTo: widget.notification.note.id,
                  preFill: "@" + widget.notification.note.author.acct + " ",
                )));
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      notification = widget.notification;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if (widget.notification.note.favourited ||
          widget.notification.note.myReaction != null) {
        favouriteColour = Colors.yellow;
      } else {
        favouriteColour = Colors.white;
      }
    });

    return Container(
        child: Column(children: <Widget>[
      Material(
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
                      widget.notification.author.avatarUrl),
                ),
              ),
              notificationTypeIcon(widget.notification.notificationType),
              Expanded(
                child: Text(widget.notification.author.nickname +
                    notificationTypeString(
                        widget.notification.notificationType)),
              ),
              Container(
                  padding: const EdgeInsets.only(right: 16.0),
                  child:
                      Icon(visIcon(notification.note.visibility), size: 16.0))
            ],
          ),
        ),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Content
          Expanded(
              child: Container(
                  padding: const EdgeInsets.only(left: 56, right: 16, top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Body
                      Container(
                        padding:
                            const EdgeInsets.only(bottom: 8.0, right: 32.0),
                        child: Text(widget.notification.note.body),
                      ),

                      Container(
                        padding:
                            const EdgeInsets.only(bottom: 8.0, right: 32.0),
                        child: widget.notification.note.statusFiles(),
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
                            Text(notification.note.renoteCount.toString()),
                          ]),

                          // Favourite
                          Row(children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.star),
                              onPressed: _toggleFavourite,
                              color: favouriteColour,
                            ),
                            Text(notification.note.favCount.toString()),
                          ]),
                        ],
                      ),
                    ],
                  ))),
        ],
      ),
      Divider(
        height: 4,
      ),
    ]));

    // notificationTile = Column(
    //   children: <Widget>[
    //     Row(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: <Widget>[
    //         // Avatar
    //         Container(
    //           alignment: FractionalOffset.topCenter,
    //           padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8),
    //           child: CircleAvatar(
    //             backgroundImage: new CachedNetworkImageProvider(
    //                 widget.notification.author.avatarUrl),
    //           ),
    //         ),

    //         // Content
    //         Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: <Widget>[
    //             // Author
    //             Container(
    //               padding: const EdgeInsets.only(bottom: 8.0, top: 8),
    //               child: Row(
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   children: <Widget>[
    //                     Expanded(
    //                         child: Column(
    //                             crossAxisAlignment: CrossAxisAlignment.start,
    //                             children: <Widget>[
    //                           // Nickname
    //                           Container(
    //                             padding: const EdgeInsets.only(right: 8.0),
    //                             child: RichText(
    //                                 maxLines: 2,
    //                                 overflow: TextOverflow.ellipsis,
    //                                 text: TextSpan(children: <TextSpan>[
    //                                   TextSpan(
    //                                       text: notificationTypeIcon(widget
    //                                           .notification.notificationType),
    //                                       style: TextStyle(
    //                                           fontFamily: 'MaterialIcons')),
    //                                   TextSpan(
    //                                       text: " " +
    //                                           widget.notification.author
    //                                               .nickname +
    //                                           notificationTypeString(widget
    //                                               .notification
    //                                               .notificationType),
    //                                       style: TextStyle(
    //                                           fontWeight: FontWeight.bold)),
    //                                 ])),
    //                           ),
    //                           // Account name
    //                           Text(widget.notification.author.acct),
    //                         ])),
    //                     Container(
    //                         padding: const EdgeInsets.only(right: 16.0),
    //                         child: Icon(
    //                             visIcon(widget.notification.note.visibility),
    //                             size: 16.0))
    //                   ]),
    //             ),

    //             // Body
    //             Container(
    //               padding: const EdgeInsets.only(bottom: 8.0, right: 32.0),
    //               child: Text(widget.notification.note.body),
    //             ),

    //             Container(
    //               padding: const EdgeInsets.only(bottom: 8.0, right: 32.0),
    //               child: widget.notification.note.statusFiles(),
    //             ),

    //             // Buttons
    //             Row(
    //               children: <Widget>[
    //                 // Reply
    //                 Row(children: <Widget>[
    //                   IconButton(
    //                     icon: Icon(Icons.reply),
    //                     onPressed: _reply,
    //                   ),
    //                   Text("0"),
    //                 ]),

    //                 // Boost
    //                 Row(children: <Widget>[
    //                   IconButton(
    //                     icon: Icon(Icons.repeat),
    //                     onPressed: _renote,
    //                   ),
    //                   Text(widget.notification.note.renoteCount.toString()),
    //                 ]),

    //                 // Favourite
    //                 Row(children: <Widget>[
    //                   IconButton(
    //                     icon: Icon(Icons.star),
    //                     onPressed: _toggleFavourite,
    //                     color: favouriteColour,
    //                   ),
    //                   Text(widget.notification.note.favCount.toString()),
    //                 ]),
    //               ],
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),
    //     Divider(
    //       height: 4,
    //     ),
    //   ],
    // );
  }
}
