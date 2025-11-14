import 'package:flutter_test/flutter_test.dart';
import 'package:scale_framework/scale_framework.dart';

main() {
  test('After adding a data binder its possible to get the data consumer', () {
    var registry = FeatureModulesRegistry();
    registry.addDataBinder<String, int>(() => StringToIntBinder());

    expect(registry.get<DataConsumer<int>>(), isNotNull);
  });
  test('After adding a data binder its possible to get the data producer', () {
    var registry = FeatureModulesRegistry();
    registry.addDataBinder<String, int>(() => StringToIntBinder());

    expect(registry.get<DataProducer<String>>(), isNotNull);
  });
  test(
      'After adding a couple of different data binders its possible to get the data consumers',
      () {
    var registry = FeatureModulesRegistry();
    registry.addDataBinder<int, String>(() => IntToStringBinder());
    registry.addDataBinder<String, int>(() => StringToIntBinder());

    expect(registry.get<DataConsumer<String>>(), isNotNull);
    expect(registry.get<DataConsumer<int>>(), isNotNull);
  });
  test(
      'After adding a couple of different data binders its possible to get the data producers',
      () {
    var registry = FeatureModulesRegistry();
    registry.addDataBinder<int, String>(() => IntToStringBinder());
    registry.addDataBinder<String, int>(() => StringToIntBinder());

    expect(registry.get<DataProducer<String>>(), isNotNull);
    expect(registry.get<DataProducer<int>>(), isNotNull);
  });
  test(
      'After adding a couple of data binders with the same production its possible to get the data producer',
      () {
    var registry = FeatureModulesRegistry();
    registry.addDataBinder<int, String>(() => IntToStringBinder());
    registry.addDataBinder<int, DateTime>(() => IntToDateTimeBinder());

    expect(registry.get<DataProducer<int>>(), isNotNull);
  });
  test(
      'After adding a couple of data binders with the same production its possible to get the data consumers',
      () {
    var registry = FeatureModulesRegistry();
    registry.addDataBinder<int, String>(() => IntToStringBinder());
    registry.addDataBinder<int, DateTime>(() => IntToDateTimeBinder());

    expect(registry.get<DataConsumer<String>>(), isNotNull);
    expect(registry.get<DataConsumer<DateTime>>(), isNotNull);
  });
}

class IntToDateTimeBinder extends DataBinder<int, DateTime> {
  @override
  DateTime map(int data) => DateTime(data);
}

class IntToStringBinder extends DataBinder<int, String> {
  @override
  String map(int data) => data.toString();
}

class StringToIntBinder extends DataBinder<String, int> {
  @override
  int map(String data) => int.parse(data);
}
