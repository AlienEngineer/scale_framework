import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:scale_framework/scale_framework.dart';

import 'testing_elements/testing_elements.dart';

class Student {
  final int age;
  final String name;
  Student({required this.age, required this.name});
}

class StudentDto {
  final String data;
  StudentDto(this.data);
}

class StudentWidget extends LoaderWidget<Student> {
  const StudentWidget({super.key});

  @override
  Widget loaded(BuildContext context, Student data) => LoadedWidget(data.name);

  @override
  Widget loading(BuildContext context) => LoadingWidget();

  @override
  Widget onError(BuildContext context, Student data) => FailureWidget();
}

class HomeWidget extends StatelessWidget {
  final int refreshId;
  const HomeWidget({
    super.key,
    this.refreshId = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          BffDataTestWidget(),
          StudentWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.refresh<BffData>({'id': refreshId});
          context.refresh<Student>({'id': refreshId});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  group('Multiple loaders first load', () {
    testWidgets('On render display loading for both loaders',
        (WidgetTester tester) async {
      await pumpApp(tester);

      expect(find.byType(LoadingWidget), findsNWidgets(2));
      await tester.pump(Duration(minutes: 1));
    });
    testWidgets(
        'after the resource has loaded '
        'display loaded widget for both loaders', (WidgetTester tester) async {
      await pumpApp(tester);
      await tester.pump(Duration(milliseconds: 5000));

      expect(find.byType(LoadedWidget), findsNWidgets(2));
      expect(find.text('some result'), findsOneWidget);
    });
    testWidgets(
        'when loading a resource fails '
        'display failure widget for both loaders', (WidgetTester tester) async {
      await pumpApp(tester, id: 500);

      expect(find.byType(FailureWidget), findsNWidgets(2));
    });

    testWidgets(
        'when refreshing a resource '
        'display loading for both loaders', (WidgetTester tester) async {
      await pumpApp(tester);
      await tester.pump(Duration(milliseconds: 5000));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump(Duration(milliseconds: 1));

      expect(find.byType(LoadingWidget), findsNWidgets(2));
      await tester.pump(Duration(minutes: 1));
    });
  });
}

Future<void> pumpApp(
  WidgetTester tester, {
  int id = 1,
  int refreshId = 1,
  bool showLoadedOnFailure = false,
  bool showLoadedOnLoading = false,
}) async {
  await tester.pumpWidget(MaterialApp(
    home: ModuleSetup(
      registry: FeatureModulesRegistry(
        featureModules: [
          TestFeatureModule(makeFakeHttpClient(), id),
        ],
      ),
      child: HomeWidget(refreshId: refreshId),
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
      factory: BffDataModelsFactory(id: id),
      uri: 'some_resource/{id}',
      client: httpClient,
    );

    registry.addLoader<Student, StudentDto>(
      mapper: MapperOfStudentDto(),
      factory: StudentModelsFactory(id: id),
      uri: 'student/{id}',
      client: httpClient,
    );
  }
}

class MapperOfStudentDto implements MapperOf<StudentDto> {
  @override
  StudentDto map(String data) => StudentDto(data);
}

class StudentModelsFactory implements LoaderModelsFactory<Student, StudentDto> {
  final int id;
  StudentModelsFactory({this.id = 1});
  @override
  Map<String, Object>? getInitialArguments() => {'id': id};

  @override
  Student makeInitialState() => Student(age: -1, name: '');

  @override
  StudentDto makeOnErrorDto(Object? error) => StudentDto('');

  @override
  Student map(StudentDto dto) => Student(age: 0, name: '');
}

MockClient makeFakeHttpClient() {
  var i = 0;
  return MockClient((request) async {
    print(request.url.toString());
    if (request.url.toString() == 'some_resource/500') {
      return http.Response("there was an error processing the request", 500);
    }
    if (request.url.toString() == 'student/500') {
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
