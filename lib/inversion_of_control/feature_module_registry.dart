import 'package:provider/single_child_widget.dart';
import 'package:scale_framework/resources/resources.dart';
import 'package:scale_framework/scale_framework.dart';
import 'package:http/http.dart' as http;

class FeatureModulesRegistry implements Registry, ModuleRegistry {
  final Map<Type, LazyRecord<Object>> _lazySingletons = {};
  final Map<Type, Object> _resolvedServices = {};
  final List<SingleChildWidget> _providers = [];
  final Map<Type, LazyRecord<Object>> _lazyProviders = {};
  final List<void Function()> _initialization = [];
  final List<FeatureModule>? featureModules;
  final List<FeatureCluster>? featureClusters;
  final List<LoaderStateManager> _loaderStateManagers = [];

  FeatureModulesRegistry({
    this.featureModules,
    this.featureClusters,
  }) {
    _setupRegistry();
  }

  void _setupRegistry() {
    if (featureModules != null) {
      for (var value in featureModules!) {
        value.setup(this);
      }
    }

    if (featureClusters != null) {
      for (var cluster in featureClusters!) {
        cluster.setup(this);
      }
    }
  }

  @override
  List<SingleChildWidget> getProviders() => _providers;

  void initialize() {
    if (_lazyProviders.isNotEmpty) {
      _lazyProviders.forEach(
        (key, value) => _storeStateManager(key, value(this) as StateManager),
      );
      _lazyProviders.clear();
    }
    for (var element in _initialization) {
      element();
    }
    _initialization.clear();
  }

  @override
  void addGlobalStateManager<T extends StateManager>(T obj) =>
      _storeStateManager(T, obj);

  void _storeStateManager(Type type, dynamic obj) {
    _providers.add(obj.getProvider());
    _resolvedServices[type] = obj;
    _initialization.add(obj.initialize);
  }

  @override
  T get<T>() {
    if (alreadyResolved<T>()) {
      return _resolvedServices[T] as T;
    }

    _resolvedServices[T] = _lazySingletons[T]?.call(this) as Object;

    return get<T>();
  }

  @override
  void addGlobalStateManagerLazy<T extends StateManager>(
    LazyRecord<T> callback,
  ) =>
      _lazyProviders[T] = (service) => callback(service) as Object;

  @override
  void addSingletonLazy<T>(T Function(ServiceCollection service) callback) =>
      _lazySingletons[T] = (service) => callback(service) as Object;

  @override
  void addModule(LazyRecord<FeatureModule> moduleBuilder) =>
      moduleBuilder(this).setup(this);

  @override
  void addDataBinder<T1, T2>(DataBinder<T1, T2> Function() binder) {
    if (alreadyRegistered<DataProducer<T1>>()) {
      var producer = get<DataProducer<T1>>();
      var composite = CompositeProducer<T1>();
      composite.add(producer);
      composite.add(binder() as DataProducer<T1>);
      _resolvedServices[DataProducer<T1>] = composite;
    } else {
      addSingletonLazy<DataProducer<T1>>(
        (_) => binder(),
      );
    }
    addSingletonLazy<DataConsumer<T2>>(
      (service) {
        var producer = service.get<DataProducer<T1>>();
        if (producer is CompositeProducer<T1>) {
          return producer.getConsumer<T2>();
        }

        return service.get<DataProducer<T1>>() as DataBinder<T1, T2>;
      },
    );
  }

  bool alreadyRegistered<T>() =>
      _resolvedServices.containsKey(T) || _lazySingletons.containsKey(T);

  bool alreadyResolved<T>() => _resolvedServices.containsKey(T);

  @override
  void addLoader<T, TDto>({
    required MapperOf<TDto> mapper,
    required LoaderModelsFactory<T, TDto> factory,
    required String uri,
    required http.Client client,
  }) {
    addSingletonLazy<MapperOf<TDto>>((_) => mapper);

    addSingletonLazy<HttpRequest<TDto>>((service) => HttpGetRequest<TDto>(
          uri: uri,
          mapper: service.get<MapperOf<TDto>>(),
          client: client,
        ));

    addGlobalStateManagerLazy((service) {
      var loaderStateManager = LoaderStateManager<T, TDto>(
        service.get<HttpRequest<TDto>>(),
        factory,
      );
      _loaderStateManagers.add(loaderStateManager);
      return loaderStateManager;
    });
  }

  @override
  LoaderStateManager getLoaderFor<T>() {
    // TODO: support multiple Loaders.
    return _loaderStateManagers.first;
  }
}

class CompositeProducer<T> implements DataProducer<T> {
  final List<DataProducer<T>> producers = [];

  @override
  void push(T data) {
    for (var producer in producers) {
      producer.push(data);
    }
  }

  void add(DataProducer<T> producer) => producers.add(producer);

  DataConsumer<T1> getConsumer<T1>() {
    return producers.whereType<DataConsumer<T1>>().first;
  }
}

abstract class FeatureModule {
  void setup(PublicRegistry registry);
}

abstract class FeatureCluster {
  void setup(ModuleRegistry registry);
}
