# Errors and debug mode

This page lists framework errors you are likely to see while wiring features.

## Debug mode

Enable it with:

```dart
ScaleFramework.enableDebugMode();
```

Current implementation adds logging around HTTP interceptor execution and interceptor errors.

## Dependency and loader errors

### `UnableToResolveDependency<T>`

Message:

```text
Unable to find service for: T
 - make sure the dependency is registered.
```

Meaning: a dependency was requested through the registry before it was registered.

### `UnableToFindStateManager<T>`

Message:

```text
Unable to find manager for: T
 - make sure registry.addLoader<T, TDto>(...) was used.
 - T and context.refresh<T>() must match.
```

Meaning: the framework could not find a loader for frontend model type `T`.

## HTTP requirement error

### `MissingRequirementsError`

Message shape:

```text
Some requirements are missing:
- fieldX
```

Meaning: a request declared required headers, but one or more of them were not provided before execution.

## HTTP status errors

| Error type | Meaning |
| --- | --- |
| `BadRequestException` | request returned `400` |
| `ResourceNotFoundException` | request returned `404` |
| `ServerException` | request returned `500` or higher |

All three extend `HttpException` and expose `statusCode`.
