# Data binding

This page describes the framework types that move data from one produced type into another.

## Core contracts

| Type | Meaning |
| --- | --- |
| `DataProducer<T>` | pushes values of type `T` |
| `DataConsumer<T>` | listens for values of type `T` |
| `DataBinder<T1, T2>` | both produces `T1` and consumes `T2` through a mapping step |

## `DataBinder<T1, T2>`

Implement:

| Member | Meaning |
| --- | --- |
| `map(T1 data)` | converts produced data into consumer data |
| `listen(void Function(T2 data) onChange)` | receives consumer callback from framework |
| `push(T1 data)` | maps and forwards produced data |

In practice, you usually implement only `map(...)`; the framework handles the rest.

## Short binder registration

```dart
registry.addBinder<Vehicle>().addConsumer((vehicle) => Brand(vehicle.brand));
```

Use this when one inline mapping is enough.

## Custom binder registration

```dart
class VehicleToBrandBinder extends DataBinder<Vehicle, Brand> {
  @override
  Brand map(Vehicle data) => Brand(data.brand);
}

registry.addDataBinder(() => VehicleToBrandBinder());
```

Use this when you want a named mapping type.

## `context.push(data)`

The framework exports:

```dart
context.push(MyEvent(...));
```

This resolves `DataProducer<MyEvent>` from the registry and pushes the value through the producer chain.

## State manager interaction

`StateManager<TState>.pushNewState(...)` also publishes the new state value to any matching `DataProducer<TState>`.

That is why binders can forward manager output into other manager state without direct imports between feature libraries.
