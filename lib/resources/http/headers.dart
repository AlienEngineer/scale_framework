abstract class HttpHeaders {
  /// Resolves a requirement with a value.
  void resolveRequirement(String requirement, String value);

  /// Get a list with all the keys that are going to be sent in the
  /// request headers
  List<String> getProvidedHeaders();
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

class DefaultHttpHeadersFactory implements HttpHeadersFactory, HttpHeaders {
  Map<String, String> resolved = {};

  @override
  Map<String, String> make() {
    ensureAllRequirementsAreResolved();
    return resolved;
  }

  @override
  void resolveRequirement(String requirement, String value) {
    resolved[requirement] = value;
  }

  @override
  void pushNeeds(List<String> needs) {
    for (var need in needs) {
      resolved[need] = 'unresolved';
    }
  }

  @override
  List<String> getProvidedHeaders() => resolved.keys.toList(growable: false);

  void ensureAllRequirementsAreResolved() {
    List<String> unresolved = [];
    resolved.forEach((key, value) {
      if (value == 'unresolved') {
        unresolved.add(key);
      }
    });

    if (unresolved.isNotEmpty) {
      throw MissingRequirementsError(unresolved);
    }
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
