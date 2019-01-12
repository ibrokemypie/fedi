import 'package:flutter/material.dart';
import 'timeline.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fedi',
      theme: ThemeData(
        primaryColor: Colors.red,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(),
        body: TimeLine(),
      ),
    );
  }
}
