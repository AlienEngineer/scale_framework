import 'package:scale_framework/resources/resources.dart';
import 'package:http/http.dart' as http;

abstract class HttpRequest<TResult> {
  Future<TResult> execute([Map<String, Object>? arguments]);
}

class HttpGetRequest<TResult> implements HttpRequest<TResult> {
  String uri;
  http.Client client;
  MapperOf<TResult> mapper;
  HttpHeadersFactory globalInterceptor;
  HttpRequestInterceptor<TResult> requestInterceptor;

  HttpGetRequest({
    required this.uri,
    required this.mapper,
    required this.client,
    this.globalInterceptor = const StubHeadersFactory(),
    this.requestInterceptor = const StubHttpRequestInterceptor(),
  });

  // TODO: ensure that all placeholders are replaced or throw exception
  @override
  Future<TResult> execute([Map<String, Object>? arguments]) async {
    var response = await client.get(
      Uri.parse(getUri(arguments)),
      headers: globalInterceptor.make(),
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

class StubHttpRequestInterceptor<TResult>
    implements HttpRequestInterceptor<TResult> {
  const StubHttpRequestInterceptor();
  @override
  HttpRequest1 intercept(HttpRequest1 request) {
    return request;
  }
}
