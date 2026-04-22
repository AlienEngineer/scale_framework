# Configure loaders and initial requests

Use this guide when a feature should fetch backend data and expose it as frontend state.

## Register a loader

```dart
registry.addLoader<Garage, GarageDto>(
  mapper: GarageDtoMapper(),
  factory: GarageModelsFactory(id: 1),
  uri: 'garages/{id}',
  options: LoaderOptions(
    showLoadedOnLoading: true,
    showLoadedOnFailure: true,
  ),
);
```

Each argument has a distinct role:

- `mapper`: converts raw response text into `GarageDto`
- `factory`: creates initial frontend state, initial request arguments, and frontend model mapping
- `uri`: target path, including placeholders such as `{id}`
- `options`: request and rendering behavior

## Choose first-request behavior

### Auto-load on app start

This is the default:

```dart
options: LoaderOptions();
```

The loader calls `refresh(factory.getInitialArguments())` during initialization.

### Defer first request

```dart
options: LoaderOptions(
  initializeOnAppStart: false,
);
```

Use this when another action should trigger the first request.

Important: with current framework behavior, a deferred loader still renders `loading()` until the first `refresh(...)` or mapped notification happens. There is no separate idle UI state.

## Decide what happens during refresh

### Keep showing previous data while refreshing

```dart
options: LoaderOptions(
  showLoadedOnLoading: true,
);
```

### Keep showing previous data when refresh fails

```dart
options: LoaderOptions(
  showLoadedOnFailure: true,
);
```

These flags matter only after the loader has already produced a successful loaded state once.

## Render with `LoaderWidget`

```dart
class GarageWidget extends LoaderWidget<Garage> {
  const GarageWidget({super.key});

  @override
  Widget loading(BuildContext context) => const CircularProgressIndicator();

  @override
  Widget loaded(BuildContext context, Garage data) => Text(data.name);

  @override
  Widget onError(BuildContext context, Garage data) =>
      const Text('Failed to load garage');
}
```
