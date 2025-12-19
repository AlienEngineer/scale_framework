import 'package:http/http.dart' as http;
import 'package:scale_framework/internal/debug_mode.dart';
import 'package:scale_framework/resources/http/interceptors/arguments_interceptor.dart';
import 'package:scale_framework/scale_framework.dart';

import 'http.dart';

class HttpModule implements FeatureModule {
  @override
  void setup(PublicRegistry registry) {
    var factory = DefaultHttpHeadersFactory();
    registry.addSingletonLazy<HttpHeadersFactory>((_) => factory);
    registry.addSingletonLazy<HttpGlobalInterception>((_) => factory);

    var httpConfiguration = HttpConfigurationInternal()
      ..addRequestInterceptors([
        httpInterceptorDecorator(ArgumentsHttpRequestInterceptor()),
      ]);

    registry.addSingletonLazy<HttpConfiguration>((_) => httpConfiguration);
    registry.addSingletonLazy<HttpConfigurationInternal>(
      (_) => httpConfiguration,
    );

    registry.addSingletonLazy<http.Client>((service) => http.Client());
  }
}
