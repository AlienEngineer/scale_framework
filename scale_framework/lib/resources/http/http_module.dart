import 'package:http/http.dart' as http;
import 'package:scale_framework/internal/debug_mode.dart';
import 'package:scale_framework/resources/http/interceptors/arguments_interceptor.dart';
import 'package:scale_framework/scale_framework.dart';

import 'http.dart';

class HttpModule implements FeatureModule {
  @override
  void setup(PublicRegistry registry) {
    var factory = DefaultHttpHeadersFactory();
    registry.addSingleton<HttpHeadersFactory>((_) => factory);
    registry.addSingleton<HttpGlobalInterception>((_) => factory);

    var httpConfiguration = HttpConfigurationInternal()
      ..addRequestInterceptors([
        httpInterceptorDecorator(ArgumentsHttpRequestInterceptor()),
      ]);

    registry.addSingleton<HttpConfiguration>((_) => httpConfiguration);
    registry.addSingleton<HttpConfigurationInternal>(
      (_) => httpConfiguration,
    );

    registry.addSingleton<http.Client>((service) => http.Client());
  }
}
