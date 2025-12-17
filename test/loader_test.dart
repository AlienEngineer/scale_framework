import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:scale_framework/scale_framework.dart';

import 'testing_elements/testing_elements.dart';

class HomeWidget extends StatelessWidget {
  final int refreshId;
  final bool showLoadedOnFailure;
  final bool showLoadedOnLoading;

  const HomeWidget({
    super.key,
    this.refreshId = 1,
    required this.showLoadedOnFailure,
    required this.showLoadedOnLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BffDataTestWidget(
        showLoadedOnFailure: showLoadedOnFailure,
        showLoadedOnLoading: showLoadedOnLoading,
      ),
      floatingActionButton: Column(
        children: [
          FloatingActionButton(
            onPressed: () => context.refresh<BffData>({'id': refreshId}),
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () => context
                .getStateManager<MyStateManager>()
                .pushData(refreshId.toString()),
            child: const Icon(Icons.multiple_stop),
          ),
        ],
      ),
    );
  }
}

class MyStateManager extends StateManager<MyId> {
  final DataProducer<MyId> producer;
  MyStateManager(this.producer) : super(MyId(''));

  void pushData(String id) => producer.push(MyId(id));
}

void main() {
  group('first load', () {
    testWidgets('On render display loading', (WidgetTester tester) async {
      await pumpApp(tester);

      expect(find.byType(LoadingWidget), findsOneWidget);

      await waitForRequestsToEnd(tester);
    });

    testWidgets('after the resource has loaded display loaded widget',
        (WidgetTester tester) async {
      await pumpApp(tester);
      await tester.pump(Duration(milliseconds: 5000));

      expect(find.byType(LoadedWidget), findsOneWidget);
      expect(find.text('some result'), findsOneWidget);
    });

    testWidgets('when loading a resource fails display failure widget',
        (WidgetTester tester) async {
      await pumpApp(tester, id: 500);

      expect(find.byType(FailureWidget), findsOneWidget);
    });
  });
  group('avoid first load', () {
    testWidgets('On render display loading', (WidgetTester tester) async {
      await pumpApp(tester, avoidFirstRequest: true);

      expect(find.byType(LoadingWidget), findsOneWidget);
    });

    testWidgets('when loader is notified loads the widget',
        (WidgetTester tester) async {
      await pumpApp(tester, avoidFirstRequest: true);

      await tester.tap(find.byIcon(Icons.multiple_stop));
      await tester.pump(Duration(milliseconds: 5000));

      expect(find.byType(LoadedWidget), findsOneWidget);
      expect(find.text('some result'), findsOneWidget);
    });

    testWidgets('when loading a resource fails display failure widget',
        (WidgetTester tester) async {
      await pumpApp(tester, refreshId: 500, avoidFirstRequest: true);

      await tester.tap(find.byIcon(Icons.multiple_stop));
      await tester.pump(Duration(milliseconds: 5000));

      expect(find.byType(FailureWidget), findsOneWidget);
    });
  });
  group('refreshing', () {
    testWidgets('[showLoadedOnLoading] display loading on first load',
        (WidgetTester tester) async {
      await pumpApp(tester, showLoadedOnLoading: true);
      await tester.pump(Duration(milliseconds: 100));

      expect(find.byType(LoadingWidget), findsOneWidget);
      await waitForRequestsToEnd(tester);
    });

    testWidgets(
        '[showLoadedOnLoading] when refreshing a resource display loaded',
        (WidgetTester tester) async {
      await pumpApp(tester, showLoadedOnLoading: true);
      await tester.pump(Duration(milliseconds: 5000));

      await tapRefresh(tester);

      expect(find.byType(LoadedWidget), findsOneWidget);
      await waitForRequestsToEnd(tester);
    });

    testWidgets(
        '[!showLoadedOnLoading] when refreshing a resource display loading',
        (WidgetTester tester) async {
      await pumpApp(tester);
      await tester.pump(Duration(milliseconds: 5000));

      await tapRefresh(tester);

      expect(find.byType(LoadingWidget), findsOneWidget);
      await waitForRequestsToEnd(tester);
    });

    testWidgets('[showLoadedOnFailure] display failure on first load',
        (WidgetTester tester) async {
      await pumpApp(tester, showLoadedOnFailure: true, id: 500);
      await tester.pump(Duration(milliseconds: 100));

      expect(find.byType(FailureWidget), findsOneWidget);
      await waitForRequestsToEnd(tester);
    });

    testWidgets(
        '[showLoadedOnFailure] after refreshing a failed resource display loaded widget with previous success',
        (WidgetTester tester) async {
      await pumpApp(tester, refreshId: 500, showLoadedOnFailure: true);
      await tester.pump(Duration(milliseconds: 5000));

      await tapRefresh(tester);

      expect(find.byType(LoadedWidget), findsOneWidget);
      expect(find.text('some result'), findsOneWidget);
    });

    testWidgets(
        '[!showLoadedOnFailure] after refreshing a failed resource display failure widget',
        (WidgetTester tester) async {
      await pumpApp(tester, refreshId: 500, showLoadedOnFailure: false);
      await tester.pump(Duration(milliseconds: 5000));

      await tapRefresh(tester);

      expect(find.byType(FailureWidget), findsOneWidget);
    });

    testWidgets('after refreshing a resource display loaded widget',
        (WidgetTester tester) async {
      await pumpApp(tester);
      await tester.pump(Duration(milliseconds: 5000));

      await tapRefresh(tester);
      await tester.pump(Duration(milliseconds: 5000));

      expect(find.byType(LoadedWidget), findsOneWidget);
      expect(find.text('some refreshed result'), findsOneWidget);
    });
  });
}

Future<void> tapRefresh(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump(Duration(milliseconds: 1));
}

class MyId {
  final String id;

  const MyId(this.id);
}

Future<void> waitForRequestsToEnd(WidgetTester tester) =>
    tester.pump(Duration(minutes: 1));

Future<void> pumpApp(
  WidgetTester tester, {
  int id = 1,
  int refreshId = 1,
  bool showLoadedOnFailure = false,
  bool showLoadedOnLoading = false,
  bool avoidFirstRequest = false,
}) async {
  await tester.pumpWidget(MaterialApp(
    home: ModuleSetup(
      registry: FeatureModulesRegistry(
        featureModules: [
          TestFeatureModule(
            makeFakeHttpClient(),
            id,
            avoidFirstRequest,
          ),
        ],
      ),
      child: HomeWidget(
        refreshId: refreshId,
        showLoadedOnFailure: showLoadedOnFailure,
        showLoadedOnLoading: showLoadedOnLoading,
      ),
    ),
  ));
  await tester.pump(Duration(milliseconds: 1));
}

class TestFeatureModule extends FeatureModule {
  final http.Client httpClient;
  final int id;
  final bool avoidFirstRequest;

  TestFeatureModule(this.httpClient, this.id, this.avoidFirstRequest);

  @override
  void setup(PublicRegistry registry) {
    registry.addGlobalStateManagerLazy(
      (service) => MyStateManager(service.get<DataProducer<MyId>>()),
    );
    var mapperToMyId = MapperToMyId();
    registry.addSingletonLazy<DataProducer<MyId>>((service) => mapperToMyId);
    registry.addLoader<BffData, BffDataDto>(
      mapper: MapperOfBffDataDto(),
      factory: BffDataModelsFactory(id: id),
      uri: 'some_resource/{id}',
      client: httpClient,
      options: LoaderOptions(
        initializeOnAppStart: !avoidFirstRequest,
        mapper: mapperToMyId,
      ),
    );
  }
}

class MapperToMyId extends DataProducerMapperOf<MyId> {
  @override
  Map<String, Object>? map(MyId data) => {'id': data.id};
}

MockClient makeFakeHttpClient() {
  var i = 0;
  return MockClient((request) async {
    if (request.url.toString() == 'some_resource/500') {
      return http.Response("there was an error processing the request", 500);
    }
    await Future.delayed(Duration(milliseconds: 2500));
    if (i > 0) {
      return http.Response("some refreshed result", 200);
    }
    ++i;
    return http.Response("some result", 200);
  });
}
