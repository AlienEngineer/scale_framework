abstract class HttpRequestInterceptor<TDto> {
  HttpRequestContext intercept(HttpRequestContext request);
}

class HttpRequestContext {
  final Uri uri;
  final Map<String, String> headers;
  final Map<String, Object>? arguments;
  HttpRequestContext(this.uri, this.headers, this.arguments);

  HttpRequestContext copyWith({
    Uri? uri,
    Map<String, String>? headers,
    Map<String, Object>? arguments,
  }) =>
      HttpRequestContext(
        uri ?? this.uri,
        {...this.headers, ...headers ?? {}},
        {...this.arguments ?? {}, ...arguments ?? {}},
      );
}
