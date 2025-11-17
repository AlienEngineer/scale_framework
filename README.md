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
