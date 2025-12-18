import 'package:scale_framework/scale_framework.dart';
import 'package:http/http.dart' as http;

extension HttpRegistrationExtensions on PublicRegistry {
  void addHttpGetRequest<TDto>({
    required String uri,
    http.Client? client,
    List<String>? requires,
  }) {
    if (alreadyRegistered<HttpRequest<TDto>>()) {
      throw UnableToRegisterHttpRequestForDto<TDto>();
    }

    addSingletonLazy<HttpRequest<TDto>>(
      (service) => HttpGetRequest<TDto>(
        uri: uri,
        mapper: service.get<MapperOf<TDto>>(),
        client: client ?? service.get<http.Client>(),
        globalInterceptor: makeFactory(service, requires),
      ),
    );
  }

  HttpHeadersFactory makeFactory(
    ServiceCollection service,
    List<String>? needs,
  ) {
    if (needs == null) {
      return StubHeadersFactory();
    }
    var headersFactory = service.get<HttpHeadersFactory>();
    headersFactory.pushNeeds(needs);
    return headersFactory;
  }
}

class UnableToRegisterHttpRequestForDto<T> extends Error {
  @override
  String toString() => "Unable to register an http request for: $T.";
}
