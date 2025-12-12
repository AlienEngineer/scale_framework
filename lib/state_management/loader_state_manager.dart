import 'package:flutter/widgets.dart';
import 'package:scale_framework/resources/resources.dart';
import 'package:scale_framework/scale_framework.dart';

class LoaderData<T> {
  final bool loaded;
  final T data;
  final bool failed;

  LoaderData({required this.loaded, required this.data, required this.failed});
}

abstract class LoaderModelsFactory<T, TDto> {
  T makeInitialState();
  Map<String, Object>? getInitialArguments();
  TDto makeOnErrorDto(Object? error);
  T map(TDto dto);
}

class LoaderStateManager<T, TDto> extends StateManager<LoaderData<T>> {
  final LoaderModelsFactory<T, TDto> modelsFactory;
  final HttpRequest<TDto> request;

  LoaderStateManager(this.request, this.modelsFactory)
      : super(LoaderData(
          loaded: false,
          data: modelsFactory.makeInitialState(),
          failed: false,
        ));

  @override
  void initialize() => refresh(modelsFactory.getInitialArguments());

  void refresh([Map<String, Object>? arguments]) {
    var execute = request.execute(arguments);
    execute.then((value) {
      pushData(value);
    }).onError((error, stackTrace) {
      pushError(error);
    });
  }

  void pushData(value) => pushNewState(
        (oldState) => LoaderData(
            data: modelsFactory.map(value), loaded: true, failed: false),
      );

  void pushError(Object? error) => pushNewState(
        (oldState) => LoaderData(
            data: modelsFactory.map(modelsFactory.makeOnErrorDto(error)),
            loaded: false,
            failed: true),
      );
}

abstract class LoaderWidget<T> extends StatelessWidget {
  const LoaderWidget({super.key});

  @override
  Widget build(BuildContext context) => StateBuilder<LoaderData<T>>(
        builder: (context, data) {
          if (data.failed) {
            return onError(context, data.data);
          }
          if (data.loaded) {
            return loaded(context, data.data);
          }
          return loading(context);
        },
      );

  Widget loading(BuildContext context);
  Widget loaded(BuildContext context, T data);
  Widget onError(BuildContext context, T data);
}
