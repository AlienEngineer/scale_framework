import 'package:scale_framework/internal/debug_mode.dart';
import 'package:scale_framework/resources/http/http.dart';

abstract class HttpConfiguration {
  void addRequestInterceptors(List<HttpRequestInterceptor> interceptors);
}

class HttpConfigurationInternal implements HttpConfiguration {
  final List<HttpRequestInterceptor> _interceptors = [];

  @override
  void addRequestInterceptors(List<HttpRequestInterceptor> interceptors) =>
      _interceptors.addAll(interceptors);

  interceptRequest(HttpRequestContext context) {
    for (int i = 0; i < _interceptors.length; ++i) {
      try {
        context = _interceptors[i].intercept(context);
      } catch (e) {
        scaleDebugPrint('Error on ${_interceptors[i].runtimeType} interceptor');
        scaleDebugPrint('error: $e\n');
      }
    }
    return context;
  }
}
