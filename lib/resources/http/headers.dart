abstract class HttpHeaders {
  void resolveRequirement(String requirement, String value);
}

abstract class HttpHeadersFactory {
  Map<String, String> make();

  void pushNeeds(List<String> needs);
}

class StubHeadersFactory implements HttpHeadersFactory {
  const StubHeadersFactory();
  @override
  Map<String, String> make() => {};

  @override
  void pushNeeds(List<String> needs) {}
}
