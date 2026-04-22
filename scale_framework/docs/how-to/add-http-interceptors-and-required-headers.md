# Add HTTP interceptors and required headers

Use this guide when requests need app-wide header data or custom request transformation.

## Add a request interceptor

```dart
class TraceIdInterceptor implements HttpRequestInterceptor {
  @override
  HttpRequestContext intercept(HttpRequestContext request) {
    return request.copyWith(
      headers: {'x-trace-id': 'trace-123'},
    );
  }
}
```

Register it from a feature module:

```dart
class GarageModule implements FeatureModule {
  @override
  void setup(PublicRegistry registry) {
    final configuration = registry.get<HttpConfiguration>();
    configuration.addRequestInterceptors([TraceIdInterceptor()]);
  }
}
```

## Require specific headers for one loader

```dart
registry.addLoader<Garage, GarageDto>(
  mapper: GarageDtoMapper(),
  factory: GarageModelsFactory(id: 1),
  uri: 'garages/{id}',
  requires: ['device'],
);
```

This tells the framework that the request must have a `device` header before execution.

## Provide required values at app setup

```dart
ModuleSetup(
  initialize: (global) {
    global.set('device', 'Android');
  },
  featureModules: [GarageModule()],
  child: const GarageScreen(),
);
```

## `set(...)` vs `resolveRequirement(...)`

- `set(key, value)` adds or overrides a header directly
- `resolveRequirement(key, value)` fills a value only if that key was previously required

For most app setup, `set(...)` is the simplest option.

## Failure mode

If a request runs before all required headers are resolved, the framework throws `MissingRequirementsError`.
