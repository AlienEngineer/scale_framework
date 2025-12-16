import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:scale_framework/resources/http/http_module.dart';
import 'package:scale_framework/resources/http/registry_extensions.dart';
import 'package:scale_framework/scale_framework.dart';
import 'package:http/http.dart' as http;

class IocContainer {
  FeatureModulesRegistry registry = FeatureModulesRegistry();

  HttpHeaders getHeaders() => registry.get<HttpHeaders>();

  HttpRequest<String> makeRequest(String uri, [List<String>? requires]) {
    registry.addModule((_) => HttpModule());
    registry.addSingletonLazy<MapperOf<String>>(
      (service) => StubStringMapper(),
    );
    registry.addHttpGetRequest<String>(
      uri: uri,
      client: makeFakeHttpClient(),
      requires: requires,
    );

    return registry.get<HttpRequest<String>>();
  }
}

void main() {
  group('executing an http get', () {
    test('returns the result successfully for 200', () async {
      var request = IocContainer().makeRequest('some_resource/1');

      var result = await request.execute();

      expect(result, 'some result');
    });
    test('providing data needs, without fulfillment throws exception',
        () async {
      var request = IocContainer().makeRequest(
        'some_resource/1',
        ['fieldX'],
      );

      expect(
        () async => await request.execute(),
        throwsA(predicate((e) {
          expect(
              e.toString(),
              'Some requirements are missing:\n'
              '- fieldX');
          return e is MissingRequirementsError;
        })),
      );
    });
    test(
        'providing data needs with fulfillment '
        'makes the request with data in headers', () async {
      var container = IocContainer();
      var request = container.makeRequest(
        'some_resource/1',
        ['fieldX'],
      );

      container.getHeaders().resolveRequirement('fieldX', 'some value');

      var result = await request.execute();

      expect(result, 'some result');
    });
    test('providing arguments will make request with those arguments',
        () async {
      var request = IocContainer().makeRequest('some_resource/{id}');

      var result = await request.execute({'id': 1});

      expect(result, 'some result');
    });
    test('throws exception when the resource was Not Found (404)', () async {
      var request = IocContainer().makeRequest('some_resource/-1');

      expect(
        () async => await request.execute(),
        throwsA(predicate(
            (e) => e is ResourceNotFoundException && e.statusCode == 404)),
      );
    });
    test('throws exception when the resource returns a server error (500)',
        () async {
      var request = IocContainer().makeRequest('some_resource/500');

      expect(
        () async => await request.execute(),
        throwsA(predicate((e) => e is ServerException && e.statusCode == 500)),
      );
    });
  });
}

MockClient makeFakeHttpClient() => MockClient((request) async {
      if (request.url.toString() == 'some_resource/1') {
        return http.Response("some result", 200);
      }
      if (request.url.toString() == 'some_resource/500') {
        return http.Response("there was an error processing the request", 500);
      }
      return http.Response('Not Found', 404);
    });

class StubStringMapper implements MapperOf<String> {
  @override
  String map(String data) => data;
}
