import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:fedi/api/authentication.dart';
import 'package:fedi/fragments/instance.dart';

class LogIn extends StatefulWidget {
  final Function setauth;
  LogIn(this.setauth);

  @override
  LogInState createState() => new LogInState();
}

class LogInState extends State<LogIn> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _instance;

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
              onPressed: () async {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  try {
                    await instanceLogin(this._instance);
                    widget.setauth(true);
                  } catch (e) {
                    print(e.toString());
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text(e.toString()),
                    ));
                  }
                }
              },
              child: Text('Submit'),
            ),
          ]),
        ),
      ),
      appBar: AppBar(),
    );
  }
}
