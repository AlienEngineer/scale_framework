import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:scale_framework/resources/http/http_module.dart';
import 'package:scale_framework/scale_framework.dart';

class ModuleSetup extends StatefulWidget {
  final List<FeatureModule>? featureModules;
  final List<FeatureCluster>? featureClusters;
  final Widget child;

  const ModuleSetup({
    super.key,
    required this.child,
    this.featureModules,
    this.featureClusters,
  });

  @override
  State<ModuleSetup> createState() => _ModuleSetupState();
}

class _ModuleSetupState extends State<ModuleSetup> {
  late FeatureModulesRegistry registry;

  @override
  void initState() {
    super.initState();
    registry = FeatureModulesRegistry(
      featureClusters: widget.featureClusters,
      featureModules: widget.featureModules,
    );
    registry.addModule((_) => HttpModule());
    registry.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<StateManagerRegistry>(
      create: (context) => StateManagerRegistry(registry),
      child: MultiBlocProvider(
        providers: registry.getProviders(),
        child: widget.child,
      ),
    );
  }
}

class StateManagerRegistry {
  final Registry registry;
  const StateManagerRegistry(this.registry);

  T getManager<T>() => registry.get<T>();
  LoaderStateManager getLoaderFor<T>() => registry.getLoaderFor<T>();
}
