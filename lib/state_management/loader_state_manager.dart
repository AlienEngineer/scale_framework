import 'package:flutter/widgets.dart';
import 'package:scale_framework/internal/debug_mode.dart';
import 'package:scale_framework/scale_framework.dart';

class LoaderData<T> {
  final bool loading;
  final bool loaded;
  final T data;
  final bool failed;

  LoaderData({
    this.loading = false,
    this.loaded = false,
    this.failed = false,
    required this.data,
  });

  LoaderData<T> copyWith({
    bool? loaded,
    T? data,
    bool? failed,
    bool? loading,
  }) =>
      LoaderData<T>(
        loading: loading ?? this.loading,
        loaded: loaded ?? this.loaded,
        data: data ?? this.data,
        failed: failed ?? this.failed,
      );
}

abstract class LoaderModelsFactory<T, TDto> {
  T makeInitialState();
  Map<String, Object>? getInitialArguments();
  TDto makeOnErrorDto(Object? error);
  T map(TDto dto);
}

extension LoaderExtensions on BuildContext {
  void refresh<T>([Map<String, Object>? arguments]) =>
      getLoaderFor<T>().refresh(arguments);
}

class LoaderNotifier<T> extends DataConsumer<T> {
  @override
  void listen(void Function(T data) onChange) {}
}

abstract class Refresher {
  void refresh([Map<String, Object>? arguments]);
}

abstract class DataProducerMapperOf<T> implements DataProducer<T> {
  late Refresher _refresher;
  void setRefresher(Refresher refresher) => _refresher = refresher;

  @override
  void push(T data) => _refresher.refresh(map(data));

  Map<String, Object>? map(T data);
}

class LoaderStateManager<T, TDto> extends StateManager<LoaderData<T>>
    implements Refresher {
  final LoaderModelsFactory<T, TDto> modelsFactory;
  final HttpRequest<TDto> request;
  final LoaderOptions options;

  LoaderStateManager(
    this.request,
    this.modelsFactory,
    this.options,
  ) : super(LoaderData(data: modelsFactory.makeInitialState()));

  @override
  void initialize() {
    if (options.initializeOnAppStart) {
      refresh(modelsFactory.getInitialArguments());
    } else {
      pushInitialState();
    }
  }

  @override
  void refresh([Map<String, Object>? arguments]) {
    pushInitialState();

    var execute = request.execute(arguments);
    execute.then((value) {
      pushData(value);
    }).onError((error, stackTrace) {
      pushError(error);
    });
  }

  void pushData(value) => pushNewState((oldState) => oldState.copyWith(
        data: modelsFactory.map(value),
        loaded: true,
        failed: false,
        loading: false,
      ));

  void pushError(Object? error) => pushNewState(
      (oldState) => oldState.copyWith(failed: true, loading: false));

  void pushInitialState() =>
      pushNewState((oldState) => oldState.copyWith(loading: true));
}

abstract class LoaderWidget<T> extends StatelessWidget {
  final bool showLoadedOnFailure;
  final bool showLoadedOnLoading;
  const LoaderWidget({
    super.key,
    this.showLoadedOnFailure = false,
    this.showLoadedOnLoading = false,
  });

  @override
  Widget build(BuildContext context) => StateBuilder<LoaderData<T>>(
        builder: (context, data) {
          if (shouldDisplayLoading(data)) {
            scaleDebugPrint('loading : $T');
            return loading(context);
          }
          if (shouldDisplayError(data)) {
            scaleDebugPrint('error : $T');
            return onError(context, data.data);
          }
          scaleDebugPrint('loaded : $T');
          return loaded(context, data.data);
        },
      );

  bool shouldDisplayError(LoaderData<dynamic> data) =>
      data.failed && (!data.loaded || !showLoadedOnFailure);

  bool shouldDisplayLoading(LoaderData<dynamic> data) =>
      data.loading && (!data.loaded || !showLoadedOnLoading);

  Widget loading(BuildContext context);
  Widget loaded(BuildContext context, T data);
  Widget onError(BuildContext context, T data);
}
