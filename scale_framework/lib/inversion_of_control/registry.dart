import 'package:provider/single_child_widget.dart';
import 'package:scale_framework/scale_framework.dart';

abstract class ModuleRegistry {
  void addModule(LazyRecord<FeatureModule> moduleBuilder);
}

typedef LazyRecord<T> = T Function(ServiceCollection service);

abstract class PublicRegistry {
  void addGlobalStateManager<T extends StateManager>(T obj);
  void addGlobalStateManagerLazy<T extends StateManager>(
      LazyRecord<T> callback);
  void addSingletonLazy<T>(LazyRecord<T> callback);
  void addDataBinder<T1, T2>(DataBinder<T1, T2> Function() binder);

  void addLoader<T, TDto>({
    required MapperOf<TDto> mapper,
    required LoaderModelsFactory<T, TDto> factory,
    required String uri,
    List<String>? requires,
    LoaderOptions? options,
  });

  bool alreadyRegistered<T>();
}

abstract class ServiceCollection {
  T get<T>();
  LoaderStateManager getLoaderFor<T>();
}

abstract class Registry implements PublicRegistry, ServiceCollection {
  List<SingleChildWidget> getProviders();
}
