import 'package:flutter/material.dart';
import 'package:navigate/navigate.dart';
import 'package:fedi/views/login.dart';
import 'package:fedi/views/timeline.dart';
import 'package:fedi/views/webauth.dart';

var loginHandler = Handler(pageBuilder: (BuildContext context, arg) {
  return LogIn();
});

var timelineHandler = Handler(pageBuilder: (BuildContext context, arg) {
  return TimeLine();
});

var webauthHandler = Handler(pageBuilder: (BuildContext context, arg) {
  return WebAuth(url: arg["url"]);
});

Map<String, Handler> routes = {
  "login": loginHandler,
  "timeline": timelineHandler,
  "webauth": webauthHandler,
};
