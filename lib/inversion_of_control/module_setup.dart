import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:scale_framework/resources/http/http_module.dart';
import 'package:scale_framework/scale_framework.dart';

class ModuleSetup extends StatefulWidget {
  final FeatureModulesRegistry registry;
  final Widget child;

  const ModuleSetup({
    super.key,
    required this.registry,
    required this.child,
  });

  @override
  State<ModuleSetup> createState() => _ModuleSetupState();
}

class _ModuleSetupState extends State<ModuleSetup> {
  @override
  void initState() {
    super.initState();
    widget.registry.addModule((_) => HttpModule());
    widget.registry.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<StateManagerRegistry>(
      create: (context) => StateManagerRegistry(widget.registry),
      child: MultiBlocProvider(
        providers: widget.registry.getProviders(),
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
