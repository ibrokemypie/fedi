import 'dart:async';
import 'dart:convert';

import 'package:fedi/fragments/instance.dart';
import 'package:http/http.dart' as http;

Future<Instance> getInstance(instanceUrl) async {
  try {
    final response = await http.get(instanceUrl + "/api/v1/instance");

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return Instance.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  } catch (exception) {
    throw exception;
  }
}
