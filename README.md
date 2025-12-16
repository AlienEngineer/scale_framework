# Scale Framework

To initialize the framework:

```dart
  // Make sure this only is instantiated once (not affected by hot reload)
  final registry = FeatureModulesRegistry(
    featureClusters: [/* Feature Clusters go here */],
    featureModules: [/* Feature Modules go here */],
  );
  MaterialApp(
    home: ModuleSetup(
      registry: registry,
      child: /* home here */,
    ),
  )
```

## Inversion Of Control

Features must expose a `FeatureModule` or `FeatureCluster` to be used by the App. These are their IOC Containers:

Example code for `FeatureModule` from `feature_1`:
```dart
class GarageModule implements FeatureModule {
  void setup(PublicRegistry registry) {
    registry.addGlobalStateManager(GarageLoader());
    registry.addGlobalStateManager(
      VehicleSelectionStateManager(vehicleSelectedNotifier),
    );
  }
}
```


Example code for `ClusterModule` from `App`:
```dart
class AppCluster implements FeatureCluster {
  @override
  void setup(ModuleRegistry registry) {
    registry.addModule(
      (service) => GarageModule(
        vehicleSelectedNotifier: service.get<DataProducer<Vehicle>>(),
      ),
    );
  }
}
```

## State Management

### Debug Mode

To show state changes in the console use:
```dart
ScaleFramework.EnableDebugMode();
```

### Loading Backend Data

To ease the access to data without much duplication we need 3 parts, a Dto Mapper, a Business Model Factory and a URI:

#### On the FeatureModule
```dart
registry.addLoader<T, TDto>(
    mapper: MapperOfDto(),    // an implementation of MapperOf<TDto>
    factory: ModelsFactory(), // an implementation of LoaderModelsFactory<T, TDto> 
    uri: 'some_url',          // the target url, can include path parameters within {} 
    client: httpClient,       // [Optional] Used for testing purposes for faking a backend.
    requires: ['some field'], // [Optional] Tells the framework that this loaders requires specific information to be provided.
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
```

For more generic usage there the example below.

### Generic Use

To manage state you'll need a `StateManager<T>`:

```dart
class TestStateManager extends StateManager<int> {
  TestStateManager() : super(0);

  // Push New State based on the previous state.
  void increment() => pushNewState((oldState) => oldState + 1);
}
```

To react as state changes:

```dart
  Scaffold(
    // React to state change 
    body: StateBuilder<TestStateManager, int>(
      builder: (context, count) => Center(child: Text('$count')),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () =>
        context.getStateManager<TestStateManager>().increment(), // force a state change.
      child: const Icon(Icons.add),
    ),
  );
```



## Sharing data between features

A feature that needs data is required to explicitly define that dependency. The feature module must receive a `DataConsumer<T>` that will need to be passed by the app. On the other hand, features that can provide data need to allow for a `DataProvider<T>` to be given. This means when a feature produce a value it has the opportunity to push that data via the `DataProvider<T>` and eventually be consumed by the app and pushed to data consumers.

## Framework Goals

This library must always be adapting to provide what features need. This includes solutions for common problems e.g. loading data from the backend with different UI responses. Request -> Load -> Processed/Error. Having solutions for common problems, makes teams move faster because they don't have to make things work again and again. Less duplication, less code, more production, more features.
