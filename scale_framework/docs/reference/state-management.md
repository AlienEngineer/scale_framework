# State management

This page describes the state primitives used for typed UI updates.

## `StateManager<TState>`

Base type for state ownership.

| Member | Meaning |
| --- | --- |
| `StateManager(TState initialState)` | creates manager with initial state |
| `currentState` | returns current state value |
| `pushNewState(TState Function(TState oldState))` | computes and emits next state |
| `initialize()` | optional startup hook called after registration |

### Behavior

- every `pushNewState(...)` updates the internal cubit state
- every `pushNewState(...)` also publishes the new value to any registered `DataProducer<TState>`
- during initialization, the framework automatically connects matching `DataConsumer<TState>` and `DataProducer<TState>` if they exist

## `StateBuilder<S>`

```dart
StateBuilder<S>(
  builder: (context, state) => ...
)
```

`StateBuilder<S>` rebuilds whenever the matching state changes.

Use it when you want a widget to react to one state type directly.

## `UpdatableWidget<S>`

`UpdatableWidget<S>` is the lower-level base class behind `StateBuilder<S>` and `LoaderWidget<T>`.

Implement:

| Member | Meaning |
| --- | --- |
| `onChange(BuildContext ctx, S state)` | renders UI from current state |

## `BuildContext` access

The framework exports:

```dart
context.getStateManager<MyManager>();
```

This resolves the registered dependency of type `MyManager`.

## Recommended usage

- keep state mutations inside managers
- use widgets to call manager methods, not to calculate next state inline
- register UI-facing state managers with `addGlobalStateManager(...)`
