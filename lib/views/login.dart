import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:fedi/api/authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fedi/views/timeline.dart';

class LogIn extends StatefulWidget {
  @override
  LogInState createState() => new LogInState();
}

class LogInState extends State<LogIn> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _instance;
  var _clickLogin;
  bool authenticated;

  @override
  void initState() {
    super.initState();
    _loadauth();
    _clickLogin = _loginAction;
    if (authenticated == true) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TimeLine()));
    }
  }

  _loadauth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      authenticated = (prefs.getBool('authenticated') ?? false);
    });
  }

  void _loginAction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_formKey.currentState.validate()) {
      setState(() {
        _clickLogin = null;
      });
      _formKey.currentState.save();
      try {
        await instanceLogin(context, this._instance);
      } catch (e) {
        print(e.toString());
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      }
      setState(() {
        authenticated = true;
        prefs.setBool('authenticated', true);
        _clickLogin = _loginAction;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(48.0),
          child: Column(children: <Widget>[
            TextFormField(
                decoration: InputDecoration(labelText: 'Instance URL:'),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.send,
                validator: (String value) {
                  if (value.length < 1) {
                    return 'Instance cannot be null';
                  }
                  if (!isURL(value)) {
                    return 'Instance must be a URL';
                  }
                  return null;
                },
                onSaved: (String value) {
                  this._instance = value;
                }),
            RaisedButton(
              onPressed: _clickLogin,
              child: Text('Submit'),
            ),
          ]),
        ),
      ),
      appBar: AppBar(),
    );
  }
}
