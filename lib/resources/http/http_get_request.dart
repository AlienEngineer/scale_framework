import 'package:scale_framework/resources/resources.dart';
import 'package:http/http.dart' as http;

abstract class HttpRequest<TResult> {
  Future<TResult> execute([Map<String, Object>? arguments]);
}

class HttpGetRequest<TResult> implements HttpRequest<TResult> {
  String uri;
  http.Client? client;
  MapperOf<TResult> mapper;
  HttpHeadersFactory headersFactory;

  HttpGetRequest({
    required this.uri,
    required this.mapper,
    this.client,
    this.headersFactory = const StubHeadersFactory(),
  });

  @override
  Future<TResult> execute([Map<String, Object>? arguments]) async {
    var response = await (client ?? http.Client()).get(
      Uri.parse(getUri(arguments)),
      headers: headersFactory.make(),
    );
    if (response.statusCode == 404) {
      throw ResourceNotFoundException(404);
    }
    if (response.statusCode == 500) {
      throw ServerException(500);
    }
    return mapper.map(response.body);
  }

  String getUri(Map<String, Object>? arguments) {
    var tempUri = uri;
    if (arguments != null) {
      arguments.forEach((key, value) {
        tempUri = tempUri.replaceFirst("{$key}", value.toString());
      });
    }
    return tempUri;
  }
}
