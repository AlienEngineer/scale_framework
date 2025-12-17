import 'package:provider/single_child_widget.dart';
import 'package:scale_framework/internal/debug_mode.dart';
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
  final Map<Type, LoaderStateManager> _loaderStateManagers = {};

  FeatureModulesRegistry({
    this.featureModules,
    this.featureClusters,
  }) {
    scaleDebugPrint('');
    scaleDebugPrint('Feature Module Registry Started');
    scaleDebugPrint('');
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

    scaleDebugPrint('');
    scaleDebugPrint('Feature Module Registry Initialized');
    scaleDebugPrint('');
  }

  @override
  void addGlobalStateManager<T extends StateManager>(T obj) =>
      _storeStateManager(T, obj);

  void _storeStateManager(Type type, dynamic obj) {
    _providers.add(obj.getProvider());
    _resolvedServices[type] = obj;
    _initialization.add(obj.initialize);
    scaleDebugPrint('added state manager: $type');
  }

  @override
  T get<T>() {
    if (alreadyResolved<T>()) {
      return _resolvedServices[T] as T;
    }

    var callback = _lazySingletons[T];
    if (callback == null) {
      throw UnableToResolveDependency<T>();
    }

    _resolvedServices[T] = callback(this);

    return get<T>();
  }

  @override
  void addGlobalStateManagerLazy<T extends StateManager>(
    LazyRecord<T> callback,
  ) =>
      _lazyProviders[T] = (service) => callback(service) as Object;

  @override
  void addSingletonLazy<T>(T Function(ServiceCollection service) callback) {
    scaleDebugPrint('added service: $T');
    _lazySingletons[T] = (service) => callback(service) as Object;
  }

  void _addSingletonLazyType(
    Type type,
    Object Function(ServiceCollection service) callback,
  ) {
    scaleDebugPrint('added service: $type');
    _lazySingletons[type] = (service) => callback(service);
  }

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
      addSingletonLazy<DataProducer<T1>>((_) => binder());
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
    http.Client? client,
    List<String>? requires,
    LoaderOptions? options,
  }) {
    addSingletonLazy<MapperOf<TDto>>((_) => mapper);
    addSingletonLazy<LoaderModelsFactory<T, TDto>>((_) => factory);

    addHttpGetRequest<TDto>(
      uri: uri,
      client: client,
      requires: requires,
    );

    addGlobalStateManagerLazy((service) {
      var loaderStateManager = LoaderStateManager<T, TDto>(
        service.get<HttpRequest<TDto>>(),
        service.get<LoaderModelsFactory<T, TDto>>(),
        options ?? LoaderOptions(),
      );

      if (options != null) {
        options.mapper.setRefresher(loaderStateManager);
        _addSingletonLazyType(
          options.mapper.getProducerType,
          (service) => options.mapper,
        );
      }

      _loaderStateManagers[T] = loaderStateManager;
      return loaderStateManager;
    });
  }

  @override
  LoaderStateManager getLoaderFor<T>() {
    if (_loaderStateManagers[T] == null) {
      throw UnableToFindStateManager<T>();
    }
    return _loaderStateManagers[T] as LoaderStateManager;
  }
}

class UnableToResolveDependency<T> extends Error {
  UnableToResolveDependency();

  @override
  String toString() => "Unable to find service for: $T\n"
      " - make sure the dependency is registered.";
}

class UnableToFindStateManager<T> extends Error {
  UnableToFindStateManager();

  @override
  String toString() => "Unable to find manager for: $T\n"
      " - make sure registry.addLoader<T, TDto>(...) was used.\n"
      " - T and context.refresh<T>() must match.";
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

  DataConsumer<T1> getConsumer<T1>() =>
      producers.whereType<DataConsumer<T1>>().first;
}

abstract class FeatureModule {
  void setup(PublicRegistry registry);
}

abstract class FeatureCluster {
  void setup(ModuleRegistry registry);
}

class LoaderOptions<T> {
  final bool initializeOnAppStart;
  final DataProducerMapperOf<T> mapper;

  const LoaderOptions({
    this.initializeOnAppStart = true,
    this.mapper = const StubMapper(),
  });
}

class StubMapper<T> implements DataProducerMapperOf<T> {
  const StubMapper();

  @override
  Map<String, Object>? map(data) => null;

  @override
  void push(data) {}

  @override
  void setRefresher(Refresher refresher) {}

  @override
  Type get getProducerType => DataProducer<T>;
}
