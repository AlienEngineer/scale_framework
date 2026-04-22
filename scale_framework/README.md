# Scale Framework

Scale Framework is a Flutter framework for feature-oriented state management, dependency registration, and backend data loading. It helps teams ship independent feature libraries, expose typed state to widgets, and model request-driven UI without rewriting the same wiring in every feature.

## Why use it

- **Feature-first composition**: each feature exposes a `FeatureModule` or `FeatureCluster`, and the app chooses how to compose them.
- **Typed state updates**: `StateManager<T>` owns state transitions and `StateBuilder<T>` rebuilds the UI when state changes.
- **Built-in request lifecycle UI**: `LoaderStateManager<T, TDto>` and `LoaderWidget<T>` cover loading, loaded, and error rendering.
- **Cross-feature communication without direct feature dependencies**: `DataBinder<T1, T2>` and `context.push(...)` let the app wire features together through framework contracts.
- **Consistent HTTP setup**: request interceptors, required headers, and URI argument replacement are part of the framework surface.

## When it fits best

Scale Framework is a good fit when you want to:

- build features as independent libraries that depend only on `scale_framework`
- keep app composition in one place instead of spreading setup across widgets
- standardize state-driven and request-driven UI patterns across features
- connect features through binders instead of direct package-to-package imports

## Core building blocks

| Building block | Purpose |
| --- | --- |
| `ModuleSetup` | Bootstraps framework, registry, providers, and HTTP support |
| `FeatureModule` | Registers dependencies for one feature |
| `FeatureCluster` | Groups several feature modules behind one composition entry point |
| `StateManager<T>` | Owns typed state and emits updates |
| `StateBuilder<T>` | Rebuilds widgets from state changes |
| `LoaderStateManager<T, TDto>` | Manages request lifecycle for one frontend model type |
| `LoaderWidget<T>` | Renders loading, loaded, and error states through dynamic dispatch |
| `DataBinder<T1, T2>` | Maps produced data from one type into another |
| `HttpConfiguration` | Registers request interceptors |

## Quick start

Wrap your app with `ModuleSetup` and give it feature modules:

```dart
MaterialApp(
  home: ModuleSetup(
    featureModules: [CounterFeatureModule()],
    child: const CountWidget(),
  ),
);
```

Create a state manager for your feature:

```dart
class CounterStateManager extends StateManager<int> {
  CounterStateManager() : super(0);

  void increment() => pushNewState((oldState) => oldState + 1);
}
```

Register it in a feature module:

```dart
class CounterFeatureModule implements FeatureModule {
  @override
  void setup(PublicRegistry registry) {
    registry.addGlobalStateManager((_) => CounterStateManager());
  }
}
```

Render it with `StateBuilder<T>`:

```dart
class CountWidget extends StatelessWidget {
  const CountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StateBuilder<int>(
        builder: (context, count) => Center(child: Text('$count')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.getStateManager<CounterStateManager>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

That gives you:

1. feature registration at app composition time
2. typed state owned by a framework-managed manager
3. UI updates driven by state instead of manual widget plumbing

## Documentation map

### Tutorials

- [Build your first feature](docs/tutorials/build-your-first-feature.md)
- [Load data with `LoaderWidget`](docs/tutorials/load-data-with-loader-widget.md)
- [Walk through the example apps](docs/tutorials/walk-through-example-apps.md)

### How-to guides

- [Register feature modules and clusters](docs/how-to/register-feature-modules-and-clusters.md)
- [Create and update state with `StateManager`](docs/how-to/create-and-update-state-with-state-manager.md)
- [Configure loaders and initial requests](docs/how-to/configure-loaders-and-initial-requests.md)
- [Refresh loaders with arguments or notifications](docs/how-to/refresh-loaders-with-arguments-or-notifications.md)
- [Share data between features with binders](docs/how-to/share-data-between-features-with-binders.md)
- [Add HTTP interceptors and required headers](docs/how-to/add-http-interceptors-and-required-headers.md)
- [Test features, loaders, and binders](docs/how-to/test-features-loaders-and-binders.md)
- [Debug and troubleshoot common problems](docs/how-to/debug-and-troubleshoot-common-problems.md)

### Reference

- [Module setup and registry](docs/reference/module-setup-and-registry.md)
- [State management](docs/reference/state-management.md)
- [Loaders](docs/reference/loaders.md)
- [Data binding](docs/reference/data-binding.md)
- [HTTP](docs/reference/http.md)
- [Errors and debug mode](docs/reference/errors-and-debug-mode.md)

### Explanation

- [How Scale Framework is structured](docs/explanation/how-scale-framework-is-structured.md)
- [Why dynamic dispatch keeps build methods clean](docs/explanation/why-dynamic-dispatch-keeps-build-methods-clean.md)
- [Why feature libraries stay isolated](docs/explanation/why-feature-libraries-stay-isolated.md)
- [How state, loaders, and binders work together](docs/explanation/how-state-loaders-and-binders-work-together.md)

## Two design rules to keep in mind

### Prefer dynamic dispatch in UI rendering

`LoaderWidget<T>` is designed so each UI state chooses its own render path through `loading`, `loaded`, and `onError`, instead of one large build method full of branching. `StateBuilder<T>` pushes you toward the same style: render from current state instead of passing control through a large conditional tree.

### Keep feature libraries isolated

Feature libraries should depend on `scale_framework`, not on each other. The app layer composes features, registers binders, and decides how information flows between independently built packages.

## Visual examples

- [Counter example walkthrough](docs/tutorials/walk-through-example-apps.md#counter-example)
- [Loader example walkthrough](docs/tutorials/walk-through-example-apps.md#loader-example)
- [Deferred loader walkthrough](docs/tutorials/walk-through-example-apps.md#deferred-loader-example)
