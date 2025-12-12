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

class TestModelsFactory implements LoaderModelsFactory<BffData, BffDataDto> {
  final int id;
  TestModelsFactory({this.id = 1});

  @override
  Map<String, Object>? getInitialArguments() => {'id': id};

  @override
  BffDataDto makeOnErrorDto(Object? error) => BffDataDto(failed: true);

  @override
  BffData map(BffDataDto dto) =>
      BffData(loaded: true, data: dto.someField, failed: dto.failed);

  @override
  BffData makeInitialState() => BffData();
}

class TestWidget extends LoaderWidget<BffData> {
  const TestWidget({super.key});

  @override
  Widget loaded(BuildContext context, BffData data) => LoadedWidget();

  @override
  Widget loading(BuildContext context) => LoadingWidget();

  @override
  Widget onError(BuildContext context, BffData data) => FailureWidget();
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
    registry.addLoader<BffData, BffDataDto>(
      mapper: MapperOfBffDataDto(),
      factory: TestModelsFactory(id: id),
      uri: 'some_resource/{id}',
      client: httpClient,
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
