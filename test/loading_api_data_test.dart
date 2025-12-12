import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:scale_framework/resources/resources.dart';
import 'package:scale_framework/scale_framework.dart';

class BffData {
  final bool loaded;
  final String data;
  final bool failed;

  BffData({
    this.loaded = false,
    this.data = "",
    this.failed = false,
  });
}

class BffDataDto {
  final String someField;
  final bool failed;

  BffDataDto({
    this.someField = "",
    this.failed = false,
  });
}

abstract class ModelsFactory<T, TDto> {
  T makeDefault();
  TDto makeOnErrorDto();
  T map(TDto dto);
}

abstract class LoaderStateManager<T, TDto> extends StateManager<T> {
  final HttpRequest<BffDataDto> request;
  LoaderStateManager(this.request, super.initialState);
}

class TestStateManager extends StateManager<BffData> {
  final HttpRequest<BffDataDto> request;
  final int id;
  TestStateManager(this.request, {this.id = 1}) : super(BffData());

  @override
  void initialize() => refreshData(id);

  void refreshData(int id) => request
      .execute({'id': id})
      .onError((error, stackTrace) => Future.value(BffDataDto(failed: true)))
      .then((value) => pushNewState((oldState) => map(value)));

  BffData map(BffDataDto dto) => BffData(
        loaded: true,
        data: dto.someField,
        failed: dto.failed,
      );
}

class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StateBuilder<TestStateManager, BffData>(
        builder: (context, data) {
          if (data.failed) {
            return FailureWidget();
          }
          if (data.loaded) {
            return LoadedWidget();
          }
          return LoadingWidget();
        },
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) => const Placeholder();
}

class LoadedWidget extends StatelessWidget {
  const LoadedWidget({super.key});

  @override
  Widget build(BuildContext context) => const Placeholder();
}

class FailureWidget extends StatelessWidget {
  const FailureWidget({super.key});

  @override
  Widget build(BuildContext context) => const Placeholder();
}

void main() {
  testWidgets('On render display loading', (WidgetTester tester) async {
    await pumpApp(tester);

    expect(find.byType(LoadingWidget), findsOneWidget);

    await tester.pump(Duration(minutes: 1));
  });
  testWidgets('after the resource is loaded display loaded widget',
      (WidgetTester tester) async {
    await pumpApp(tester);
    await tester.pump(Duration(milliseconds: 5000));

    expect(find.byType(LoadedWidget), findsOneWidget);
  });
  testWidgets('when loading a resource fails display failure widget',
      (WidgetTester tester) async {
    await pumpApp(tester, id: 500);

    expect(find.byType(FailureWidget), findsOneWidget);
  });
}

Future<void> pumpApp(WidgetTester tester, {int id = 1}) async {
  await tester.pumpWidget(MaterialApp(
    home: ModuleSetup(
      registry: FeatureModulesRegistry(
        featureModules: [
          TestFeatureModule(makeFakeHttpClient(), id),
        ],
      ),
      child: TestWidget(),
    ),
  ));
  await tester.pump(Duration(milliseconds: 1));
}

class TestFeatureModule extends FeatureModule {
  final http.Client httpClient;
  final int id;

  TestFeatureModule(this.httpClient, this.id);

  @override
  void setup(PublicRegistry registry) {
    registry.addSingletonLazy<MapperOf<BffDataDto>>(
      (_) => MapperOfBffDataDto(),
    );

    registry.addSingletonLazy<HttpRequest<BffDataDto>>(
      (service) => HttpGetRequest<BffDataDto>(
        uri: 'some_resource/{id}',
        mapper: service.get<MapperOf<BffDataDto>>(),
        client: httpClient,
      ),
    );

    registry.addGlobalStateManagerLazy(
      (service) => TestStateManager(
        service.get<HttpRequest<BffDataDto>>(),
        id: id,
      ),
    );
  }
}

class MapperOfBffDataDto implements MapperOf<BffDataDto> {
  @override
  BffDataDto map(String data) => BffDataDto(someField: data);
}

MockClient makeFakeHttpClient() => MockClient((request) async {
      if (request.url.toString() == 'some_resource/500') {
        return http.Response("there was an error processing the request", 500);
      }
      await Future.delayed(Duration(milliseconds: 2500));
      return http.Response("some result", 200);
    });
