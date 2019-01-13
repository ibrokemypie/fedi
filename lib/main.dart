import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fedi/views/timeline.dart';
import 'package:fedi/views/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Fedi();
  }
}

class FediState extends State<Fedi> {
  bool authenticated;

  @override
  void initState() {
    super.initState();
    _loadauth();
  }

  _loadauth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      authenticated = (prefs.getBool('authenticated') ?? false);
    });
  }

  _setauth(value) async {
    if (value != authenticated) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        prefs.setBool('authenticated', value);
        authenticated = value;
        print("authenticated: " + authenticated.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (authenticated == true) {
      body = TimeLine(_setauth);
    } else {
      body = LogIn(_setauth);
    }

    return MaterialApp(
      title: 'fedi',
      theme: ThemeData(
        primaryColor: Colors.red,
        brightness: Brightness.dark,
      ),
      home: body,
    );
  }
}

class Fedi extends StatefulWidget {
  @override
  FediState createState() => new FediState();
}
