# Loaders

This page describes the request-driven state types used by the framework.

## Registering a loader

```dart
registry.addLoader<T, TDto>(
  mapper: ...,
  factory: ...,
  uri: 'resource/{id}',
  requires: ['device'],
  options: LoaderOptions(),
);
```

| Argument | Meaning |
| --- | --- |
| `T` | frontend model type rendered by widgets and used by `context.refresh<T>()` |
| `TDto` | parsed response type produced by `MapperOf<TDto>` |
| `mapper` | maps raw response body into `TDto` |
| `factory` | builds initial frontend state, initial request arguments, and `TDto -> T` mapping |
| `uri` | request URI, including placeholders such as `{id}` |
| `requires` | header names that must be provided before execution |
| `options` | loader behavior flags and optional notification mapper |

## `LoaderModelsFactory<T, TDto>`

| Member | Meaning |
| --- | --- |
| `makeInitialState()` | frontend state before first successful request |
| `getInitialArguments()` | arguments used by the first request when auto-load is enabled |
| `map(TDto dto)` | converts parsed DTO into frontend model |

## `LoaderOptions<T>`

| Field | Default | Meaning |
| --- | --- | --- |
| `initializeOnAppStart` | `true` | whether loader should trigger its first request during initialization |
| `mapper` | `const StubMapper()` | optional `DataProducerMapperOf<T>` used to convert pushed data into refresh arguments |
| `showLoadedOnFailure` | `false` | whether a refresh failure should keep showing the previous loaded UI |
| `showLoadedOnLoading` | `false` | whether a refresh in progress should keep showing the previous loaded UI |

## `LoaderStateManager<T, TDto>`

`LoaderStateManager<T, TDto>` is a `StateManager<LoaderData<T>>` plus `Refresher`.

### Behavior

- if `initializeOnAppStart` is `true`, it calls `refresh(factory.getInitialArguments())`
- if `initializeOnAppStart` is `false`, it still pushes the loading render state
- `refresh(...)` starts a request and then moves to loaded or error rendering
- successful requests map `TDto` into `T`
- failed refreshes either show error UI or preserve old loaded UI based on `showLoadedOnFailure`
- refreshing after success either shows loading UI or preserves old loaded UI based on `showLoadedOnLoading`

## `LoaderData<T>`

| Field | Meaning |
| --- | --- |
| `loaded` | whether the loader has produced a loaded state at least once |
| `data` | current frontend model |

`LoaderData<T>` also owns the render function that decides whether `loading`, `loaded`, or `onError` should be called.

## `LoaderWidget<T>`

Implement these methods:

| Member | Meaning |
| --- | --- |
| `loading(BuildContext context)` | UI for loading state |
| `loaded(BuildContext context, T data)` | UI for successful state |
| `onError(BuildContext context, T data)` | UI for failed state; receives current frontend data |

## `context.refresh<T>()`

```dart
context.refresh<Garage>();
context.refresh<Garage>({'id': 42});
```

`T` must match the frontend model type used at loader registration time.

## `DataProducerMapperOf<T>`

Use `DataProducerMapperOf<T>` when pushed data should trigger a loader refresh:

```dart
class GarageSelectionMapper extends DataProducerMapperOf<GarageSelection> {
  @override
  Map<String, Object>? map(GarageSelection data) => {'id': data.id};
}
```

When registered in `LoaderOptions<T>`, pushing `GarageSelection` calls `refresh(...)` with the mapped arguments.
