import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:fedi/views/login.dart';
import 'package:fedi/views/timeline.dart';


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