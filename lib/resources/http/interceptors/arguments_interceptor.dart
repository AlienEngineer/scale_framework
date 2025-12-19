import 'package:scale_framework/resources/http/http.dart';

class ArgumentsHttpRequestInterceptor implements HttpRequestInterceptor {
  const ArgumentsHttpRequestInterceptor();

  @override
  HttpRequestContext intercept(HttpRequestContext request) => request.copyWith(
        uri: getUri(request.uri, request.arguments),
      );

  Uri getUri(Uri uri, Map<String, Object>? arguments) =>
      uri.replace(pathSegments: convertSegments(uri, arguments ?? {}));

  // TODO: ensure that all placeholders are replaced or throw exception
  List<String> convertSegments(Uri uri, Map<String, Object>? arguments) =>
      uri.pathSegments.map((e) {
        if (e.startsWith('{') && e.endsWith('}')) {
          var key = e.substring(1, e.length - 1);
          return arguments![key].toString();
        }
        return e;
      }).toList();
}
