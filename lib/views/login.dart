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
          child: Column(
            children: <Widget>[
              TextFormField(
                  decoration: InputDecoration(labelText: 'Instance URL:'),
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
                onPressed: () {
                  // Validate will return true if the form is valid, or false if
                  // the form is invalid.
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    print(this._instance);
                    getInstance(this._instance).then((instance) {
                      print(instance.toJson());
                      widget.setauth(true);
                    }).catchError((error) {
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text(error.toString()),
                      ));
                    });
                  }
                },
                child: Text('Submit'),
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(),
    );
  }
}