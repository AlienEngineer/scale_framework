abstract class HttpRequestInterceptor<TDto> {
  HttpRequest1 intercept(HttpRequest1 request);
}

class HttpRequest1 {
  final Uri _uri;
  final Map<String, String> _headers;
  HttpRequest1(this._uri, this._headers);

  HttpRequest1 copyWith({Uri? uri, Map<String, String>? headers}) =>
      HttpRequest1(uri ?? _uri, {..._headers, ...headers ?? {}});
}
