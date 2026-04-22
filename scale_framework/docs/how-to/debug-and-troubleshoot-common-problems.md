# Debug and troubleshoot common problems

Use this guide when framework wiring is not behaving the way you expect.

## Turn on debug mode

```dart
ScaleFramework.enableDebugMode();
```

Current debug mode decorates HTTP interceptors and prints:

- interceptor runtime type
- URI before and after interception
- request arguments before and after interception
- interceptor errors raised during request processing

## Common problems

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `Unable to find service for: T` | dependency was never registered | register it with `addSingleton(...)`, `addGlobalStateManager(...)`, `addLoader(...)`, or another registry method |
| `Unable to find manager for: T` | no loader exists for that frontend model type, or `context.refresh<T>()` uses wrong `T` | make sure `addLoader<T, TDto>(...)` was registered and `refresh<T>()` uses the same `T` |
| `Some requirements are missing:` | loader declared `requires`, but app did not provide those headers before execution | set required headers inside `ModuleSetup.initialize(...)` |
| deferred loader stays on loading UI | `initializeOnAppStart: false` delays the request, but loader still renders `loading()` until first trigger | call `context.refresh<T>(...)` or `context.push(...)` with a mapped notifier |
| feature packages need each other directly | composition logic is living in the wrong layer | move binders and cross-feature orchestration into app composition layer |

## Fast checks

1. Confirm the module containing the dependency is included in `ModuleSetup`.
2. Confirm the generic type used by widgets matches the generic type used at registration.
3. Confirm required headers are provided before the request runs.
4. Confirm deferred loaders receive a refresh or mapped push event.
