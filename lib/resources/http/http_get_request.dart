import 'package:scale_framework/resources/resources.dart';
import 'package:http/http.dart' as http;

class HttpGetRequest<TResult> {
  String uri;
  http.Client? client;
  MapperOf<TResult> mapper;

  HttpGetRequest({
    required this.uri,
    required this.mapper,
    this.client,
  });

  Future<TResult> execute() async {
    var response = await (client ?? http.Client()).get(Uri.parse(uri));
    if (response.statusCode == 404) {
      throw ResourceNotFoundException(404);
    }
    if (response.statusCode == 500) {
      throw ServerException(500);
    }
    return mapper.map(response.body);
  }
}
