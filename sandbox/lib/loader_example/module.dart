import 'package:http/http.dart' as http;
import 'package:sandbox/loader_example/fake_server.dart';
import 'package:scale_framework/scale_framework.dart';

import 'loader.dart';
import 'widget.dart';

class TestFeatureModule extends FeatureModule {
  final int id;

  TestFeatureModule(this.id);

  @override
  void setup(PublicRegistry registry) {
    registry.addSingletonLazy<http.Client>((service) => makeFakeHttpClient());
    registry.addLoader<BffData, BffDataDto>(
      mapper: MapperOfBffDataDto(),
      factory: BffDataModelsFactory(id: id),
      uri: 'https://mydomain.com/some_resource/{id}',
    );
  }
}
