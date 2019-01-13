import 'package:flutter/material.dart';
import 'status.dart';
import 'user.dart';

class TimeLine extends StatelessWidget {
  final Function setauth;
  TimeLine(this.setauth);

  static const String lipsum =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam finibus erat sed dui eleifend fermentum feugiat at augue. Nulla eget ullamcorper tellus. Cras nec varius ex, id ultricies nisi. Nullam at porta tortor, at vehicula est. Maecenas convallis est eu sodales laoreet. Phasellus consectetur varius velit ac pulvinar. Nulla mi augue, sagittis sed sollicitudin eu, consectetur posuere diam. Nam dapibus metus purus, eget porttitor enim hendrerit eget. Nunc tempus justo eu ante ullamcorper, eget dignissim orci commodo. Etiam ac libero orci. Curabitur at venenatis elit. Donec ultricies urna et rhoncus bibendum.";

  @override
  Widget build(BuildContext context) {
    var me = User.fromJson({
      "username": "ibrokemypie",
      "nickname": "pie",
      "host": "boopsnoot.gq",
      "id": "smth",
      "avatarUrl":
          "https://boopsnoot.gq/files/5c2e16f3815ad75dc3c42a69?thumbnail"
    });

    var statuses = <Status>[
      Status.fromJson({
        "author": me,
        "title": "one",
        "body": lipsum,
        "id": 1.toString(),
        "date": "1/1/2000",
        "visibility": "public"
      }),
      Status.fromJson({
        "author": me,
        "title": "two",
        "body": "lol",
        "id": 2.toString(),
        "date": "1/1/2000",
        "visibility": "direct"
      }),
    ];

    return Scaffold(
      body: ListView.builder(
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2; /*3*/
          if (index >= statuses.length) {
            return null;
          }
          return statusBuilder(statuses[index]);
        },
      ),
      drawer: Drawer(),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              setauth(false);
            },
          )
        ],
      ),
    );
  }
}
