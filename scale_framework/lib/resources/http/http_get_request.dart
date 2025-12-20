import 'package:scale_framework/resources/resources.dart';
import 'package:http/http.dart' as http;

import 'http_configuration.dart';

abstract class HttpRequest<TResult> {
  Future<TResult> execute([Map<String, Object>? arguments]);
}

class HttpGetRequest<TResult> implements HttpRequest<TResult> {
  String uri;
  http.Client client;
  MapperOf<TResult> mapper;
  HttpHeadersFactory globalInterceptor;
  final HttpConfigurationInternal httpConfiguration;

  HttpGetRequest({
    required this.uri,
    required this.mapper,
    required this.client,
    required this.httpConfiguration,
    this.globalInterceptor = const StubHeadersFactory(),
  });

  @override
  Future<TResult> execute([Map<String, Object>? arguments]) async {
    var context = httpConfiguration.interceptRequest(_makeContext(arguments));

    var response = await client.get(context.uri, headers: context.headers);

    if (response.statusCode == 404) {
      throw ResourceNotFoundException(404);
    }
    if (response.statusCode == 500) {
      throw ServerException(500);
    }
    return mapper.map(response.body);
  }

  HttpRequestContext _makeContext(Map<String, Object>? arguments) =>
      HttpRequestContext(
        Uri.parse(uri),
        globalInterceptor.make(),
        arguments,
      );

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
  HttpRequestContext intercept(HttpRequestContext request) {
    return request;
  }
}
