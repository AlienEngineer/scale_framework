import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:scale_framework/scale_framework.dart';

class ModuleSetup extends StatelessWidget {
  final FeatureModulesRegistry registry;
  final Widget child;

  const ModuleSetup({
    super.key,
    required this.registry,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Provider<StateManagerRegistry>(
      create: (context) => StateManagerRegistry(registry),
      child: MultiBlocProvider(
        providers: registry.getProviders(),
        child: child,
      ),
    );
  }
}

class StateManagerRegistry {
  final Registry registry;
  const StateManagerRegistry(this.registry);

  T getManager<T>() => registry.get<T>();
}
