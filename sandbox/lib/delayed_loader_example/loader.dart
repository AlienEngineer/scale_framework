import 'package:scale_framework/scale_framework.dart';

import 'widget.dart';

class BffDataDto {
  final String someField;

  BffDataDto({this.someField = ""});
}

class MapperOfBffDataDto implements MapperOf<BffDataDto> {
  @override
  BffDataDto map(String data) => BffDataDto(someField: data);
}

class BffDataModelsFactory implements LoaderModelsFactory<BffData, BffDataDto> {
  final int id;
  BffDataModelsFactory({this.id = 1});

  @override
  Map<String, Object>? getInitialArguments() => {'id': id};

  @override
  BffDataDto makeOnErrorDto(Object? error) => BffDataDto();

  @override
  BffData map(BffDataDto dto) => BffData(data: dto.someField);

  @override
  BffData makeInitialState() => BffData();
}
