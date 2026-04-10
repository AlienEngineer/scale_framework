# Scale Framework - Copilot Instructions

## Project Overview

Scale Framework is a Flutter state management and dependency injection framework designed to reduce boilerplate and accelerate feature development. It provides:

- **State Management**: Type-safe state management with `StateManager<T>` and reactive `StateBuilder<T>` widgets
- **Backend Data Loading**: First-class support for HTTP data loading with `LoaderStateManager` and `LoaderWidget`
- **Inversion of Control**: Module-based dependency injection via `FeatureModule` and `FeatureCluster`
- **Data Binding**: Cross-feature communication through `DataBinder<T1, T2>` without tight coupling
- **HTTP Configuration**: Extensible request interceptor system

## Build, Test, and Lint Commands

```bash
# Run all tests
flutter test

# Run a single test file
flutter test test/loader_test.dart

# Run tests matching a name pattern
flutter test --name "On render display loading"

# Analyze code (uses flutter_lints)
flutter analyze

# Format code
dart format .
```

## Architecture Overview

### Dependency Registration Flow

1. **App Initialization**: `ModuleSetup` widget wraps the app root
2. **Module Registration**: `FeatureCluster` registers `FeatureModule` instances
3. **Dependency Setup**: Each `FeatureModule.setup()` registers dependencies in `PublicRegistry`
4. **Provider Tree**: Registry builds a `MultiBlocProvider` tree for runtime access

```dart
// App structure
MaterialApp(
  home: ModuleSetup(
    featureClusters: [AppCluster()],
    featureModules: [FeatureModule1(), FeatureModule2()],
    child: HomeWidget(),
  ),
)
```

### State Management Layers

**Layer 1: Basic State**
- `StateManager<T>`: Holds state of type `T`, exposes `pushNewState()`
- `StateBuilder<T>`: Widget that rebuilds when state changes
- Access via `context.getStateManager<ManagerType>()`

**Layer 2: Loader State**
- `LoaderStateManager<T, TDto>`: Manages HTTP request lifecycle (loading → loaded/failed)
- `LoaderWidget<T>`: Abstract widget with `loading()`, `loaded()`, `onError()` methods
- Registered via `registry.addLoader<T, TDto>(mapper, factory, uri)`

**Layer 3: Data Binding**
- `DataBinder<T1, T2>`: Listens to `StateManager<T1>`, pushes transformed data to `StateManager<T2>`
- Enables cross-feature communication without direct dependencies
- Registered via `registry.addDataBinder()` or `registry.addBinder<T>().addConsumer<T1>()`

### HTTP Request Flow

1. **Registration**: `addLoader<T, TDto>()` creates `HttpRequest<TDto>` + `LoaderStateManager<T, TDto>`
2. **Interception**: Request passes through `HttpRequestInterceptor` chain
3. **Mapping**: Response `TDto` → `T` via `LoaderModelsFactory<T, TDto>`
4. **State Update**: `LoaderStateManager` pushes `LoaderData<T>` with loading/loaded/failed flags
5. **UI Rendering**: `LoaderWidget<T>` renders appropriate UI based on state

## Key Conventions

### Module Structure

- **`FeatureModule`**: Registers dependencies for a single feature (state managers, loaders, binders)
- **`FeatureCluster`**: Groups related `FeatureModule` instances (typically one per major feature area)
- **Naming**: Use `{Feature}Module` for modules, `{Feature}Cluster` for clusters
- Always implement `setup(PublicRegistry registry)` for modules, `setup(ModuleRegistry registry)` for clusters

### StateManager Conventions

- **Constructor**: Always call `super(initialState)` with the initial state value
- **State Updates**: Use `pushNewState((oldState) => newState)` - never mutate state directly
- **Global vs Local**: Register global state with `addGlobalStateManager()`, local/scoped state with `addSingleton()`
- **Initialization**: Override `initialize()` for setup logic after registration (e.g., `LoaderStateManager` auto-refreshes here)

### Loader Registration

Required parameters for `addLoader<T, TDto>()`:
- `mapper`: `MapperOf<TDto>` - deserializes HTTP response to `TDto`
- `factory`: `LoaderModelsFactory<T, TDto>` - provides initial state, maps `TDto` → `T`, handles errors
- `uri`: String - can include path parameters with `{param}` syntax

Optional parameters:
- `requires`: List of header field names that must be provided via global interceptor
- `options.initializeOnAppStart`: Auto-refresh on initialization (default: true)
- `options.mapper`: `DataProducerMapperOf<T>` for push-based refresh (notifications)

### Path Parameter Replacement

```dart
// In registration
registry.addLoader<Data, DataDto>(uri: 'api/items/{id}', ...);

// In usage
context.refresh<Data>({'id': 123}); // Becomes 'api/items/123'
```

### LoaderWidget Patterns

- `showLoadedOnFailure: true` - Keep showing previous data when refresh fails
- `showLoadedOnLoading: true` - Keep showing previous data while refreshing (prevents flicker)
- Override `loading()`, `loaded(context, data)`, `onError(context, data)` methods
- Never store state in `LoaderWidget` - it's stateless, use `StateManager` instead

### Testing

- **HTTP Mocking**: Use `http.MockClient` for testing loaders (not included by default in registry)
- **Widget Tests**: Use `pumpApp(tester)` pattern to wrap with `ModuleSetup`
- **Finders**: Use `find.byType(LoadingWidget)`, `find.byType(LoadedWidget)` for loader states
- **mocktail**: Preferred mocking library (see test files for examples)

### Debug Mode

Enable debug logging:
```dart
ScaleFramework.enableDebugMode(); // Logs state changes and HTTP interceptors
```

## Common Patterns

### Push Notification to Loader

Use when you want to trigger a loader refresh in response to another state change:

```dart
// In registration
registry.addLoader<MyModel, MyDto>(
  // ... other params
  options: LoaderOptions<MyModel>(
    mapper: MyModelNotificationMapper(), // Maps MyModel to path params
  ),
);

// In usage
context.push<MyModel>(model); // Refreshes loader with mapped params
```

### Cross-Feature Data Flow

```dart
// Producer feature registers a StateManager<FeatureAData>
// Consumer feature registers a StateManager<FeatureBData>

// In a module (often consumer's):
registry.addDataBinder((_) => FeatureAToFeatureBBinder());

class FeatureAToFeatureBBinder extends DataBinder<FeatureAData, FeatureBData> {
  @override
  FeatureBData map(FeatureAData data) => FeatureBData(data.someField);
}
```

### HTTP Interceptor Setup

```dart
ModuleSetup(
  initialize: (global) {
    global.set('Authorization', 'Bearer token');
    global.set('device', 'Android');
  },
  // ...
)

// In a FeatureModule
var config = registry.get<HttpConfiguration>();
config.addRequestInterceptors([MyCustomInterceptor()]);
```

## File Organization

```
lib/
├── scale_framework.dart           # Main export file
├── inversion_of_control/          # DI/IOC system
│   ├── registry.dart               # Core registry abstractions
│   ├── module_setup.dart           # Root widget for setup
│   └── build_context_extensions.dart
├── state_management/               # State management primitives
│   ├── state_manager.dart          # Base StateManager<T>
│   ├── state_builder.dart          # Reactive widget
│   ├── loader_state_manager.dart   # HTTP loader + LoaderWidget
│   └── data_binders.dart           # Cross-feature binding
└── resources/                      # HTTP and resource loading
    ├── http/                       # HTTP client, interceptors
    └── registry_extensions.dart    # addLoader, addHttpGetRequest
```

## Private Package

This package is published to a private registry (OnePub). Do not attempt to publish to pub.dev.
