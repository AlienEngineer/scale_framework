## Basic Counter App

To create a widget that handles data loading from a backend.

### Data From Backend

```dart
class BffDataDto {
  final String someField;

  BffDataDto({this.someField = ""});
}
```

## Frontend Data

```dart

class BffData {
  final String data;

  BffData({this.data = ""});
}
```

### Widget

```dart
class BffDataWidget extends LoaderWidget<BffData> {
  const BffDataWidget({super.key});

  @override
  Widget loaded(BuildContext context, BffData data) => LoadedWidget(data.data);

  @override
  Widget loading(BuildContext context) => LoadingWidget();

  @override
  Widget onError(BuildContext context, BffData data) => FailureWidget();
}
```

## Mapping between BE to FE

```dart
// MapperOf<DTO> Receives the data from the backend and creates a dart object. This is the edge of our request. 
class MapperOfBffDataDto implements MapperOf<BffDataDto> {
  @override
  BffDataDto map(String data) => BffDataDto(someField: data);
}

// LoaderModelsFactory<BffData, BffDataDto> Deals with all interactions of the Loader.
// creates default values, maps DTO to Business Model, etc
class BffDataModelsFactory implements LoaderModelsFactory<BffData, BffDataDto> {
  final int id;
  BffDataModelsFactory({this.id = 1});

  // Defines what values should be used on the first request.
  // This assumes that the loader will make a request on app start. (can be avoided during configuration)
  @override
  Map<String, Object>? getInitialArguments() => {'id': id};

  // Defines what should happen when the loader fails to load the data.
  @override
  BffDataDto makeOnErrorDto(Object? error) => BffDataDto();

  // Maps the DTO to the Business Model
  @override
  BffData map(BffDataDto dto) => BffData(data: dto.someField);

  // First state of the loader before the first request has even started.
  @override
  BffData makeInitialState() => BffData();
}
```
### Feature Module

```dart
class MyFeatureModule extends FeatureModule {
  @override
  void setup(PublicRegistry registry) {
    
    // Links the previous Mappers to the loader
    // Defines the request URI
    registry.addLoader<BffData, BffDataDto>(
      mapper: MapperOfBffDataDto(),
      factory: BffDataModelsFactory(id: id),
      uri: 'some_resource/{id}',
    );
  }
}
```

### Putting it all together

```dart
MaterialApp(
  home: ModuleSetup(
    featureModules: [MyFeatureModule()],
    child: BffDataWidget(),
  ),
)
```