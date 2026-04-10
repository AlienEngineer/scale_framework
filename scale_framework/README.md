# Scale Framework

### Examples:

- [simple counter app](example/simple_counter_app.md)
- [data_loader app](example/backend_data_loader_sample_app.md)

To initialize the framework:

```dart

  MaterialApp(
    home: ModuleSetup(
      featureClusters: [/* Feature Clusters go here */],
      featureModules: [/* Feature Modules go here */],
      child: /* home here */,
    ),
  )
```

### Debug Mode

To show state changes in the console use:
```dart
ScaleFramework.EnableDebugMode();
```

## Inversion Of Control

Features must expose a `FeatureModule` or `FeatureCluster` to be used by the App. These are their IOC Containers:

### Feature Module

A feature module should contain all dependencies that our feature requires.

Example code for `FeatureModule` from `feature_1`:
```dart
class GarageModule implements FeatureModule {
  void setup(PublicRegistry registry) {
    registry.addGlobalStateManager((_) => GarageLoader());
    registry.addGlobalStateManager((_) => VehicleSelectionStateManager());
  }
}
```

### Cluster Module

A cluster module is a collection of feature modules.


Example code for `ClusterModule` from `App`:
```dart
class AppCluster implements FeatureCluster {
  @override
  void setup(ModuleRegistry registry) {
    registry.addModule((_) => GarageModule());
  }
}
```

## State Management

### Loading Backend Data

To ease the access to data without much duplication we need 3 parts, a Dto Mapper, a Business Model Factory and a URI:

#### On the FeatureModule

```dart
registry.addLoader<T, TDto>(
    mapper: MapperOfDto(),            // an implementation of MapperOf<TDto>
    factory: ModelsFactory(),         // an implementation of LoaderModelsFactory<T, TDto> 
    uri: 'some_url',                  // the target url, can include path parameters within {} 
    client: httpClient,               // [Optional] Used for testing purposes for faking a backend.
    requires: ['some field'],         // [Optional] Tells the framework that this loaders requires specific information to be provided.
    options: LoaderOptions<MyModel>(  // [Optional] Defines options in behaviour for the loader
        initializeOnAppStart: true,   // [Optional - Default: true] Defines if the loading should happen automatically on start.
        mapper: MapperToMyId(),       // [Optional] Defines a mapper to be used for notifications. See "Notify Loader" below.
    )
);
```

After this is done, we can go ahead and implement our Widget that will define what happens when a response comes in from the backend.
In the example, `BackendData` holds the mapped data from the implementation in `LoaderModelsFactory<T, TDto>`.

```dart
class MyWidget extends LoaderWidget<BackendData> {
  const MyWidget({super.key}): super(
    // Keeps displaying the loaded state when refresh fails.
    showLoadedOnFailure: false, // Optional, false by default
    // Keeps displaying the loaded state while refreshing.
    showLoadedOnLoading: false, // Optional, false by default
  );

  @override
  Widget loaded(BuildContext context, BackendData data) =>
      LoadedWidget();

  @override
  Widget loading(BuildContext context) =>
      LoadingWidget();

  @override
  Widget onError(BuildContext context, BackendData data) =>
      FailureWidget();
}
```

Whenever you want to refresh data from the backend just call:
```dart
context.refresh<BackendData>(); // Replace BackendData with your type.

// Provide data to be replaced in the path of the http request
// in this example a path with {field} is going to be replaced by 1
// e.g. 'mypath/{field}' would be converted into 'mypath/1'
context.refresh<BackendData>({ 'field': 1 });
```

### Notify Loader

Having defined a mapper for the notifier then one can do:
```dart
context.push<MyModel>(); // Sends a notification to the loader that can handle MyModal.
```

`MyModel` is going to be captured by the mapper defined in `LoaderOptions<T>` (T must be MyModel) during `addLoader`. 


For more generic usage there the example below.

### Generic Use

To manage state you'll need a `StateManager<T>`:

```dart
class TestStateManager extends StateManager<int> {
  TestStateManager() : super(0 /* Initial state */);

  // Push New State based on the previous state.
  void increment() => pushNewState((oldState) => oldState + 1);
}
```

To react as state changes:

```dart
  Scaffold(
    // React to state change of a given type
    body: StateBuilder<int>(
      builder: (context, count) => Center(child: Text('$count')),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () =>
        context.getStateManager<TestStateManager>().increment(), // force a state change.
      child: const Icon(Icons.add),
    ),
  );
```

## Http Configuration

The framework includes a way to manipulate the http requests via `HttpRequestInterceptor` and in order to configure an interceptor one must:

```dart
// access HttpConfiguration via registry
var configuration = registry.get<HttpConfiguration>();

configuration.addRequestInterceptors([
  /* MyCustomRequestInterceptor */
]);
```

The global interceptor is available in the `ModuleSetup`.

```dart
ModuleSetup(
  initialize: (global) {
    global.set('device', 'Android');
  },
  //...
)
```

## Sharing data between features

All state managers produce data whenever a `pushNewState` is called. This gives an opportunity to capture this data and transform it to push data into another state manager. 
In order to do this, we only need to set it up like so:
```dart
registry
    .addBinder<SomeTypeProduced>()
    // data is an instance of SomeTypeProduced. 
    // the next line maps that data into another data type.
    .addConsumer((data) => SomeTypeConsumed());
```

An alternative way for more complex mappings would be to create a `DataBinder<T1, T2>` like so:

```dart
// register the data binder.
registry.addDataBinder((_) => Type1ToType2Binder());

// some implementation for that data binder.
class Type1ToType2Binder extends DataBinder<Type1, Type2> {
  Type2 map(Type1 data) => Type2();
}
```

As long as there is a `StateManager<Type2>` it will receive data when a Type1 is pushed onto a `StateManager<Type1>`. 

## Framework Goals

This library must always be adapting to provide what features need. This includes solutions for common problems e.g. loading data from the backend with different UI responses. Request -> Load -> Processed/Error. Having solutions for common problems, makes teams move faster because they don't have to make things work again and again. Less duplication, less code, more production, more features.
