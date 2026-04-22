# Build your first feature

This tutorial walks through the smallest useful Scale Framework feature: a counter with its own state manager, module registration, and UI.

## What you will build

By the end, you will have:

- one feature module
- one state manager
- one widget that reacts to state
- one app root that composes the feature

## Step 1: Create state manager

`StateManager<T>` owns the state for one feature concern. Start with an integer counter:

```dart
class CounterStateManager extends StateManager<int> {
  CounterStateManager() : super(0);

  void increment() => pushNewState((oldState) => oldState + 1);
}
```

Two things matter here:

1. `super(0)` defines the initial state.
2. `pushNewState(...)` creates the next value from the current one.

## Step 2: Register feature dependencies

Expose the feature through a `FeatureModule`:

```dart
class CounterFeatureModule implements FeatureModule {
  @override
  void setup(PublicRegistry registry) {
    registry.addGlobalStateManager((_) => CounterStateManager());
  }
}
```

Use `addGlobalStateManager` for state managers that must be available to widgets through the framework provider tree.

## Step 3: Build widget that reacts to state

`StateBuilder<T>` rebuilds whenever the matching state changes:

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

The important relationship is:

- `context.getStateManager<CounterStateManager>()` finds the manager
- `increment()` pushes a new state
- `StateBuilder<int>` rebuilds with that new integer value

## Step 4: Compose feature at app root

`ModuleSetup` is the entry point that wires the registry and providers:

```dart
MaterialApp(
  home: ModuleSetup(
    featureModules: [CounterFeatureModule()],
    child: const CountWidget(),
  ),
);
```

That is enough to run the feature.

## What happened

You just used Scale Framework in its most direct form:

1. feature module declared dependencies
2. framework registered state manager
3. widget read manager from context
4. builder reacted to typed state

This is the basic pattern that the rest of the framework builds on.

## Next step

Continue with [Load data with `LoaderWidget`](load-data-with-loader-widget.md) to see how the same composition model handles backend requests.
