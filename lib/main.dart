import 'package:flutter/material.dart';
import 'package:fedi/views/login.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Fedi();
  }
}

class FediState extends State<Fedi> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
