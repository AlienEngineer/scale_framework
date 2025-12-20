import 'package:flutter/widgets.dart';
import 'package:scale_framework/scale_framework.dart';

import 'test_widgets.dart';

class BffData {
  final String data;

  BffData({this.data = ""});
}

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

class BffDataTestWidget extends LoaderWidget<BffData> {
  const BffDataTestWidget({
    super.showLoadedOnFailure,
    super.showLoadedOnLoading,
    super.key,
  });

  @override
  Widget loaded(BuildContext context, BffData data) => LoadedWidget(data.data);

  @override
  Widget loading(BuildContext context) => LoadingWidget();

  @override
  Widget onError(BuildContext context, BffData data) => FailureWidget();
}
