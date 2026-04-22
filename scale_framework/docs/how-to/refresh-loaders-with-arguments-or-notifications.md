# Refresh loaders with arguments or notifications

Use this guide when a loader must react to user input, navigation state, or another framework event.

## Refresh with explicit arguments

Given a loader registered with URI placeholders:

```dart
registry.addLoader<Garage, GarageDto>(
  mapper: GarageDtoMapper(),
  factory: GarageModelsFactory(id: 1),
  uri: 'garages/{id}',
);
```

Refresh it like this:

```dart
context.refresh<Garage>({'id': 42});
```

Rules:

- `Garage` must match the frontend model type from `addLoader<Garage, GarageDto>(...)`
- placeholder replacement happens on URI path segments such as `{id}`

## Refresh from pushed data

If another framework event should drive refresh, add a `DataProducerMapperOf<T>`:

```dart
class GarageSelection {
  final String id;
  const GarageSelection(this.id);
}

class GarageSelectionMapper extends DataProducerMapperOf<GarageSelection> {
  @override
  Map<String, Object>? map(GarageSelection data) => {'id': data.id};
}
```

Register it through loader options:

```dart
registry.addLoader<Garage, GarageDto>(
  mapper: GarageDtoMapper(),
  factory: GarageModelsFactory(id: 1),
  uri: 'garages/{id}',
  options: LoaderOptions<GarageSelection>(
    initializeOnAppStart: false,
    mapper: GarageSelectionMapper(),
  ),
);
```

Trigger it by pushing data:

```dart
context.push(GarageSelection('42'));
```

Use this when the loader should follow another domain event instead of a direct widget call to `refresh(...)`.
