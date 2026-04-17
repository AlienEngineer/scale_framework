import 'package:flutter/widgets.dart';
import 'package:scale_framework/scale_framework.dart';

class RenderContext<T> {
  final BuildContext context;
  final LoadingBuilderFunction loading;
  final BuilderFunction<T> loaded;
  final BuilderFunction<T> onError;

  RenderContext(this.context, this.loading, this.loaded, this.onError);
}

typedef BuilderFunction<T> = Widget Function(BuildContext context, T data);
typedef LoaderRenderFunction<T> = Widget Function(
  RenderContext<T> renderContext,
);
typedef LoadingBuilderFunction = Widget Function(BuildContext context);

class LoaderData<T> {
  final bool loaded;
  final T data;
  final LoaderRenderFunction<T> _renderFunction;

  LoaderData({
    this.loaded = false,
    required this.data,
    LoaderRenderFunction<T>? renderFunction,
  }) : _renderFunction =
            renderFunction ?? ((context) => context.loading(context.context));

  LoaderData<T> _setError(Object? error) => LoaderData<T>(
      loaded: loaded,
      data: data,
      renderFunction: (context) => context.onError(context.context, data));

  LoaderData<T> _setLoading() => LoaderData<T>(
      loaded: loaded,
      data: data,
      renderFunction: (context) => context.loading(context.context));

  LoaderData<T> _setLoaded(T data) => LoaderData<T>(
      loaded: true,
      data: data,
      renderFunction: (context) => context.loaded(context.context, data));

  Widget build(
    BuildContext context,
    LoadingBuilderFunction loading,
    BuilderFunction<T> loaded,
    BuilderFunction<T> onError,
  ) =>
      _renderFunction(RenderContext(context, loading, loaded, onError));
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
      pushNewState((oldState) => oldState._setLoaded(modelsFactory.map(value)));

  void pushError(Object? error) {
    pushNewState((oldState) {
      if (shouldDisplayError(oldState)) {
        return oldState._setError(error);
      }
      return oldState._setLoaded(oldState.data);
    });
  }

  void pushInitialState() {
    pushNewState((oldState) {
      if (shouldDisplayLoading(oldState)) {
        return oldState._setLoading();
      }
      return oldState._setLoaded(oldState.data);
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
  Widget build(BuildContext context) {
    return StateBuilder<LoaderData<T>>(
      builder: (context, data) => data.build(
        context,
        loading,
        loaded,
        onError,
      ),
    );
  }

  Widget loading(BuildContext context);

  Widget loaded(BuildContext context, T data);

  Widget onError(BuildContext context, T data);
}
