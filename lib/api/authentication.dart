import 'package:fedi/fragments/instance.dart';
import 'package:http/http.dart' as http;

instanceLogin(String instanceUrl) async {
  Instance instance = await Instance.fromUrl(instanceUrl);
  print(instance.toJson());
  switch (instance.type) {
    case "misskey":
      {
        final response = await http.get(instance.uri + "/api/v1/instance");

        if (response.statusCode == 200) {
          // If server returns an OK response, parse the JSON
        } else {
          throw Exception('Failed to load post');
        }
        break;
      }
    default:
      {
        throw Exception(instance.type + " isnt supported lol");
      }
  }
}
