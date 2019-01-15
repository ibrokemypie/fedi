import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fedi/views/timeline.dart';
import 'package:fedi/views/login.dart';
import 'package:fluro/fluro.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Fedi();
  }
}

class FediState extends State<Fedi> {
  final router = Router();

  var loginHandler =
      Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return LogIn();
  });
  var timelineHandler =
      Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return TimeLine();
  });

  void defineRoutes(Router router) {
    router.define("/login", handler: loginHandler);
    router.define("/timeline", handler: timelineHandler);
  }

  @override
  void initState() {
    super.initState();
    defineRoutes(router);
  }

  Route<dynamic> genRoute(RouteSettings route) {
    Route<dynamic> returned = router.generator(route);
    return returned;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // onGenerateRoute: router.generator,
      onGenerateRoute: genRoute,
      title: 'fedi',
      theme: ThemeData(
        primaryColor: Colors.red,
        brightness: Brightness.dark,
      ),
      home: LogIn(),
    );
  }
}

class Fedi extends StatefulWidget {
  @override
  FediState createState() => new FediState();
}
