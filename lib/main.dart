import 'package:flutter/material.dart';
import 'package:fedi/views/login.dart';
import 'package:fluro/fluro.dart';
import 'package:fedi/definitions/routes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Fedi();
  }
}

class FediState extends State<Fedi> {
  final router = Router();

  @override
  void initState() {
    super.initState();
    defineRoutes(router);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: router.generator,
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
