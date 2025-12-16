import 'package:flutter_test/flutter_test.dart';
import 'package:scale_framework/resources/http/headers.dart';

void main() {
  test('getting headers by default return empty headers', () {
    var factory = DefaultHttpHeadersFactory();

    var headers = factory.make();

    expect(headers, {});
  });
  test(
      'returns empty headers '
      'when resolving a requirement that was not required', () {
    var factory = DefaultHttpHeadersFactory();
    factory.resolveRequirement('fieldX', 'value of fieldX');

    var headers = factory.make();

    expect(headers, {});
  });
  test(
      'returns headers '
      'when resolving a requirement that was required', () {
    var factory = DefaultHttpHeadersFactory();
    factory.pushNeeds(['fieldX']);
    factory.resolveRequirement('fieldX', 'value of fieldX');

    var headers = factory.make();

    expect(headers, {'fieldX': 'value of fieldX'});
  });
}
