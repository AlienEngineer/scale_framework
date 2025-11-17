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
