import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:scale_framework/resources/http/http_module.dart';
import 'package:scale_framework/scale_framework.dart';
import 'package:http/http.dart' as http;

class IocContainer {
  FeatureModulesRegistry registry = FeatureModulesRegistry();

  HttpGlobalInterception getHttpGlobalInterceptor() =>
      registry.get<HttpGlobalInterception>();

  HttpRequest<String> makeRequest(String uri, [List<String>? requires]) {
    setupHttpRequest(uri, requires);

    return getRequest();
  }

  HttpRequest<String> getRequest() => registry.get<HttpRequest<String>>();

  void setupHttpRequest(String uri, [List<String>? requires]) {
    registry.addModule((_) => HttpModule());
    registry.addSingletonLazy<MapperOf<String>>(
      (service) => StubStringMapper(),
    );

    registry.addSingletonLazy<http.Client>((service) => makeFakeHttpClient());
    registry.addHttpGetRequest<String>(
      uri: uri,
      requires: requires,
    );
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

      container
          .getHttpGlobalInterceptor()
          .resolveRequirement('fieldX', 'some value');

      var result = await request.execute();

      expect(result, 'some result');
    });

    test(
        'providing header data '
        'makes the request with data in headers', () async {
      var container = IocContainer();
      var request = container.makeRequest(
        'some_resource/1',
        ['fieldX'],
      );

      container.getHttpGlobalInterceptor().set('fieldX', 'some value');

      var result = await request.execute();

      expect(result, 'some result');
    });

    test(
        'providing header data '
        'makes the request with data in headers'
        'even when its not required', () async {
      var container = IocContainer();
      var request = container.makeRequest(
        'some_resource/2',
        ['fieldX'],
      );

      var interceptor = container.getHttpGlobalInterceptor();
      interceptor.set('fieldX', 'some value');
      interceptor.set('fieldY', 'this is the value of fieldY');

      var result = await request.execute();

      expect(result, 'this is the value of fieldY');
    });

    test(
        'resolving more requirements than what is needed '
        'makes the request with just the needed data in headers', () async {
      var container = IocContainer();
      var request = container.makeRequest(
        'some_resource/1',
        ['fieldX'],
      );

      var interceptor = container.getHttpGlobalInterceptor();
      interceptor.resolveRequirement('fieldX', 'some value');
      // This fieldY is going to be ignored as it is not needed.
      interceptor.resolveRequirement('fieldY', 'some value');

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

  group('multiple requests', () {
    test('execute a couple of requests returns the expected results', () async {
      var container = IocContainer();
      container.setupHttpRequest('some_resource/{id}');
      var request = container.getRequest();

      var result1 = await request.execute({'id': 1});
      var result2 = await request.execute({'id': 2});

      expect(result1, 'some result');
      expect(result2, 'some result 2');
    });
  });
}

MockClient makeFakeHttpClient() => MockClient((request) async {
      if (request.url.toString() == 'some_resource/2' &&
          request.headers.keys.length > 1) {
        return http.Response(request.headers['fieldY'].toString(), 200);
      }
      if (request.headers.keys.length > 1) {
        return http.Response("invalid headers", 500);
      }
      if (request.url.toString() == 'some_resource/1') {
        return http.Response("some result", 200);
      }
      if (request.url.toString() == 'some_resource/2') {
        return http.Response("some result 2", 200);
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
