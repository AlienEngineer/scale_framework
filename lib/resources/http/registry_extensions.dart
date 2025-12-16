import 'package:scale_framework/scale_framework.dart';
import 'package:http/http.dart' as http;

extension HttpRegistrationExtensions on Registry {
  void addHttpGetRequest<TDto>({
    required String uri,
    required http.Client client,
    List<String>? requires,
  }) =>
      addSingletonLazy<HttpRequest<TDto>>((service) {
        if (requires != null) {
          return HttpGetRequest<TDto>(
            uri: uri,
            mapper: service.get<MapperOf<TDto>>(),
            client: client,
            headersFactory: makeFactory(service, requires),
          );
        }
        return HttpGetRequest<TDto>(
          uri: uri,
          mapper: service.get<MapperOf<TDto>>(),
          client: client,
        );
      });

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

class MissingRequirementsError extends Error {
  final List<String> unresolved;
  MissingRequirementsError(this.unresolved);

  @override
  String toString() {
    return "Some requirements are missing:\n"
        "${unresolved.map((e) => '- $e').join('\n')}";
  }
}
