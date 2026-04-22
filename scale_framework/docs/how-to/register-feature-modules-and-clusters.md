# Register feature modules and clusters

Use this guide when you already know what feature you want to add and only need the wiring pattern.

## Register one feature module directly

```dart
class GarageModule implements FeatureModule {
  @override
  void setup(PublicRegistry registry) {
    registry.addGlobalStateManager((_) => GarageStateManager());
  }
}

MaterialApp(
  home: ModuleSetup(
    featureModules: [GarageModule()],
    child: const GarageScreen(),
  ),
);
```

Use this when the app can compose the feature directly and no extra grouping is needed.

## Group several features with a cluster

```dart
class AppCluster implements FeatureCluster {
  @override
  void setup(ModuleRegistry registry) {
    registry.addModule((_) => GarageModule());
    registry.addModule((_) => ProfileModule());
  }
}

MaterialApp(
  home: ModuleSetup(
    featureClusters: [AppCluster()],
    child: const HomeScreen(),
  ),
);
```

Use a cluster when one higher-level package or app wants to expose a curated group of modules.

## Set app-wide HTTP values during setup

`ModuleSetup` accepts an `initialize` callback for global HTTP header setup:

```dart
ModuleSetup(
  initialize: (global) {
    global.set('device', 'Android');
    global.set('authorization', 'Bearer token');
  },
  featureModules: [GarageModule()],
  child: const GarageScreen(),
);
```

## What `ModuleSetup` does for you

- creates the registry
- registers the framework HTTP module automatically
- initializes registered state managers
- builds the provider tree used by `StateBuilder` and `LoaderWidget`

You do **not** need to register `HttpModule` yourself when you use `ModuleSetup`.
