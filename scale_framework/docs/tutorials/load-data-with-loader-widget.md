# Load data with `LoaderWidget`

This tutorial shows how to build a feature that loads backend data and renders loading, loaded, and error UI through Scale Framework.

## What you will build

You will create:

- a DTO for raw backend data
- a frontend model for widget use
- a `MapperOf<TDto>` for response parsing
- a `LoaderModelsFactory<T, TDto>` for frontend state
- a `LoaderWidget<T>` for state-driven rendering

## Step 1: Define DTO and frontend model

Keep transport and UI models separate:

```dart
class BffDataDto {
  final String someField;

  BffDataDto({this.someField = ''});
}

class BffData {
  final String data;

  BffData({this.data = ''});
}
```

## Step 2: Map response and frontend state

The request mapper handles raw response parsing. The loader factory handles frontend state.

```dart
class MapperOfBffDataDto implements MapperOf<BffDataDto> {
  @override
  BffDataDto map(String data) => BffDataDto(someField: data);
}

class BffDataModelsFactory implements LoaderModelsFactory<BffData, BffDataDto> {
  final int id;

  BffDataModelsFactory({this.id = 1});

  @override
  BffData makeInitialState() => BffData();

  @override
  Map<String, Object>? getInitialArguments() => {'id': id};

  @override
  BffData map(BffDataDto dto) => BffData(data: dto.someField);
}
```

Use this split when:

- backend payload shape is not your widget shape
- initial UI state should exist before first request
- URI arguments should be provided automatically on app start

## Step 3: Register loader

Register the loader inside your feature module:

```dart
class MyFeatureModule implements FeatureModule {
  @override
  void setup(PublicRegistry registry) {
    registry.addLoader<BffData, BffDataDto>(
      mapper: MapperOfBffDataDto(),
      factory: BffDataModelsFactory(id: 1),
      uri: 'some_resource/{id}',
    );
  }
}
```

The two generic types have different jobs:

- `BffData` is the frontend model your widgets render
- `BffDataDto` is the parsed response type returned by the request mapper

## Step 4: Render with `LoaderWidget`

`LoaderWidget<T>` uses dynamic dispatch instead of one large conditional build method:

```dart
class BffDataWidget extends LoaderWidget<BffData> {
  const BffDataWidget({super.key});

  @override
  Widget loaded(BuildContext context, BffData data) => Text(data.data);

  @override
  Widget loading(BuildContext context) => const Placeholder();

  @override
  Widget onError(BuildContext context, BffData data) => const Placeholder();
}
```

You implement one method per UI state:

- `loading`
- `loaded`
- `onError`

## Step 5: Compose feature

```dart
MaterialApp(
  home: ModuleSetup(
    featureModules: [MyFeatureModule()],
    child: const BffDataWidget(),
  ),
);
```

With default options, the loader runs on app start and uses `getInitialArguments()` for its first request.

## Step 6: Refresh manually

Call `context.refresh<T>()` with the same frontend model type used by `addLoader<T, TDto>`:

```dart
context.refresh<BffData>();
context.refresh<BffData>({'id': 42});
```

If your URI contains placeholders such as `some_resource/{id}`, the framework replaces those path segments from the provided argument map.

## Optional: Trigger refresh from pushed data

Sometimes another interaction should refresh the loader. In that case, provide a `DataProducerMapperOf<T>` in `LoaderOptions<T>`:

```dart
class MyId {
  final String id;
  const MyId(this.id);
}

class MapperToMyId extends DataProducerMapperOf<MyId> {
  @override
  Map<String, Object>? map(MyId data) => {'id': data.id};
}

registry.addLoader<BffData, BffDataDto>(
  mapper: MapperOfBffDataDto(),
  factory: BffDataModelsFactory(id: 1),
  uri: 'some_resource/{id}',
  options: LoaderOptions<MyId>(
    initializeOnAppStart: false,
    mapper: MapperToMyId(),
  ),
);
```

Then push the notification:

```dart
context.push(MyId('42'));
```

## One behavior to know early

If you set `initializeOnAppStart: false`, the loader does **not** make a request on startup, but it still renders `loading()` until you trigger `refresh(...)` or push a mapped notification. Scale Framework currently has loading, loaded, and error UI states, but not a separate idle state.

## Next step

Read [Walk through the example apps](walk-through-example-apps.md) for a visual map from these concepts to the shipped examples.
