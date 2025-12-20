import 'package:scale_framework/scale_framework.dart';

import 'state_manager.dart';

class CounterFeatureModule extends FeatureModule {
  @override
  void setup(PublicRegistry registry) {
    registry.addGlobalStateManager(CounterStateManager());
  }
}
