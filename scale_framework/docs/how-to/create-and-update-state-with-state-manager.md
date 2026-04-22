# Create and update state with `StateManager`

Use this guide when you want one feature to own typed state and update the UI from it.

## 1. Define manager

```dart
class CounterStateManager extends StateManager<int> {
  CounterStateManager() : super(0);

  void increment() => pushNewState((oldState) => oldState + 1);
}
```

`pushNewState(...)` is the normal way to move state forward. Keep state transitions inside the manager instead of scattering them across widgets.

## 2. Register manager

```dart
class CounterFeatureModule implements FeatureModule {
  @override
  void setup(PublicRegistry registry) {
    registry.addGlobalStateManager((_) => CounterStateManager());
  }
}
```

Use `addGlobalStateManager(...)` for managers that power widget rebuilds. Use `addSingleton(...)` for collaborators such as clients, mappers, or configuration objects.

## 3. Read and update from widget

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

## 4. Run initialization logic when needed

Override `initialize()` if the manager needs startup work after registration:

```dart
class SessionStateManager extends StateManager<String> {
  SessionStateManager() : super('');

  @override
  void initialize() {
    pushNewState((_) => 'ready');
  }
}
```

## Tips

- Use one manager per feature concern.
- Keep widgets dumb; let managers own state transitions.
- Let `StateBuilder<T>` render the value type you care about, not the manager type.
