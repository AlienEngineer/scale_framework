import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

MockClient makeFakeHttpClient() {
  var i = 0;
  return MockClient((request) async {
    if (request.url.toString() == 'https://mydomain.com/some_resource/500') {
      return http.Response("there was an error processing the request", 500);
    }
    await Future.delayed(Duration(milliseconds: 2500));
    if (i > 0) {
      return http.Response("some refreshed result", 200);
    }
    ++i;
    return http.Response("some result", 200);
  });
}
