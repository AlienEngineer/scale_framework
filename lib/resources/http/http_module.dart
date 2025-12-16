import 'package:scale_framework/scale_framework.dart';

class HttpModule implements FeatureModule {
  @override
  void setup(PublicRegistry registry) {
    var factory = DefaultHttpHeadersFactory();
    registry.addSingletonLazy<HttpHeadersFactory>((service) => factory);
    registry.addSingletonLazy<HttpHeaders>((service) => factory);
  }
}
