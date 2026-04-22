# Module setup and registry

This page describes the framework types used to compose features and register dependencies.

## `ModuleSetup`

`ModuleSetup` is the root widget for framework composition.

| Property | Type | Meaning |
| --- | --- | --- |
| `child` | `Widget` | widget rendered inside the framework provider tree |
| `featureModules` | `List<FeatureModule>?` | feature modules registered directly by the app |
| `featureClusters` | `List<FeatureCluster>?` | grouped feature collections registered by the app |
| `initialize` | `void Function(HttpGlobalInterception global)?` | hook for setting global HTTP header values before registry initialization |

### Runtime behavior

`ModuleSetup`:

1. creates `FeatureModulesRegistry`
2. prepends `HttpModule()` to the module list
3. calls `initialize(...)` if provided
4. initializes registered state managers
5. exposes `StateManagerRegistry` through `Provider`
6. exposes manager providers through `MultiBlocProvider`

## `FeatureModule`

```dart
abstract class FeatureModule {
  void setup(PublicRegistry registry);
}
```

Use a feature module to register all dependencies owned by one feature library.

## `FeatureCluster`

```dart
abstract class FeatureCluster {
  void setup(ModuleRegistry registry);
}
```

Use a cluster when one package or app needs to expose a curated group of modules.

## `ModuleRegistry`

| Member | Meaning |
| --- | --- |
| `addModule(LazyRecord<FeatureModule> moduleBuilder)` | registers another feature module from inside a cluster |

## `PublicRegistry`

| Member | Meaning |
| --- | --- |
| `addGlobalStateManager<T extends StateManager>(...)` | registers a state manager and adds its provider to the widget tree |
| `addSingleton<T>(...)` | registers a lazily resolved singleton service |
| `addDataBinder<T1, T2>(...)` | registers a custom `DataBinder<T1, T2>` |
| `addLoader<T, TDto>(...)` | registers request mapper, loader factory, loader manager, and HTTP request for one frontend model type |
| `alreadyRegistered<T>()` | reports whether a type is already registered or resolved |
| `addBinder<T>()` | starts a short-form binder registration for producer type `T` |

## `ServiceCollection`

| Member | Meaning |
| --- | --- |
| `get<T>()` | resolves a registered dependency or throws |
| `getLoaderFor<T>()` | resolves the loader registered for frontend model type `T` |
| `tryGet<T>(fallback)` | resolves a dependency or returns a fallback value |

## `LazyRecord<T>`

```dart
typedef LazyRecord<T> = T Function(ServiceCollection service);
```

Registry callbacks receive `ServiceCollection`, so registrations can depend on other registered services.
