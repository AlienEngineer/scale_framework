import 'package:flutter/widgets.dart';
import 'package:scale_framework/scale_framework.dart';

class LoaderData<T> {
  final bool loaded;
  final T data;

  Widget Function(BuildContext context)? loadingFunction;

  Widget Function(BuildContext context, T data)? loadedFunction;

  Widget Function(BuildContext context, T data)? onErrorFunction;

  Widget Function(BuildContext contect, T data, LoaderData<T> self)?
      currentFunction;

  LoaderData({
    this.loaded = false,
    required this.data,
    this.currentFunction,
    this.loadingFunction,
    this.loadedFunction,
    this.onErrorFunction,
  });

  LoaderData<T> setError(Object? error) => LoaderData<T>(
        loaded: loaded,
        data: data,
        currentFunction: (context, data, self) {
          return self.onErrorFunction!(context, data);
        },
        loadingFunction: loadingFunction,
        loadedFunction: loadedFunction,
        onErrorFunction: onErrorFunction,
      );

  LoaderData<T> setLoading() => LoaderData<T>(
        loaded: loaded,
        data: data,
        currentFunction: (context, data, self) {
          return self.loadingFunction!(context);
        },
        loadingFunction: loadingFunction,
        loadedFunction: loadedFunction,
        onErrorFunction: onErrorFunction,
      );

  LoaderData<T> setLoaded(T data) => LoaderData<T>(
        loaded: true,
        data: data,
        currentFunction: (context, data, self) {
          return self.loadedFunction!(context, data);
        },
        loadingFunction: loadingFunction,
        loadedFunction: loadedFunction,
        onErrorFunction: onErrorFunction,
      );

  Widget build(BuildContext context) => currentFunction!(context, data, this);

  void bind(
    Widget Function(BuildContext context) loading,
    Widget Function(BuildContext context, T data) loaded,
    Widget Function(BuildContext context, T data) onError,
  ) {
    loadingFunction = loading;
    loadedFunction = loaded;
    onErrorFunction = onError;
  }
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
  Type get getProducerType => DataProducer<T>;
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

  void pushData(value) =>
      pushNewState((oldState) => oldState.setLoaded(modelsFactory.map(value)));

  void pushError(Object? error) {
    pushNewState((oldState) {
      if (shouldDisplayError(oldState)) {
        return oldState.setError(error);
      }
      return oldState.setLoaded(oldState.data);
    });
  }

  void pushInitialState() {
    pushNewState((oldState) {
      if (shouldDisplayLoading(oldState)) {
        return oldState.setLoading();
      }
      return oldState.setLoaded(oldState.data);
    });
  }

  bool shouldDisplayError(LoaderData<T> data) =>
      !data.loaded || !options.showLoadedOnFailure;

  bool shouldDisplayLoading(LoaderData<T> data) =>
      !data.loaded || !options.showLoadedOnLoading;
}

abstract class LoaderWidget<T> extends StatelessWidget {
  const LoaderWidget({super.key});

  @override
  Widget build(BuildContext context) => StateBuilder<LoaderData<T>>(
        builder: (context, data) {
          // todo: find a way to restructure this. This way we bind every time the widget rebuilds. But these never change.
          data.bind(
            loading,
            loaded,
            onError,
          );

          return data.build(context);
        },
      );

  Widget loading(BuildContext context);

  Widget loaded(BuildContext context, T data);

  Widget onError(BuildContext context, T data);
}
