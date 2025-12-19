import 'package:scale_framework/resources/http/http.dart';

import 'internal/debug_mode.dart';

export 'inversion_of_control/inversion_of_control.dart';
export 'state_management/state_management.dart';
export 'resources/resources.dart';
export 'resources/http/registry_extensions.dart';

class ScaleFramework {
  /// This enables debug mode.
  ///
  /// Makes the framework print:
  /// - state changes
  /// - bump the registered dependencies
  static void enableDebugMode() {
    scaleDebugPrint = print;
    httpInterceptorDecorator = (interceptor) => LogHttpInterceptor(interceptor);
  }
}

class LogHttpInterceptor implements HttpRequestInterceptor {
  final HttpRequestInterceptor interceptor;
  const LogHttpInterceptor(this.interceptor);

  @override
  HttpRequestContext intercept(HttpRequestContext request) {
    scaleDebugPrint('running : ${interceptor.runtimeType}');
    scaleDebugPrint('before-> uri : ${request.uri}');
    scaleDebugPrint('before-> arguments : ${request.arguments}');
    var context = interceptor.intercept(request);

    scaleDebugPrint('after-> uri : ${context.uri}');
    scaleDebugPrint('after-> arguments : ${context.arguments}');
    return context;
  }
}
