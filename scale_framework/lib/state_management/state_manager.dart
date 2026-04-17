import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scale_framework/scale_framework.dart';

class Timer {
  static final stopwatch = Stopwatch();
  static void start() => stopwatch.start();
  static void stop() => stopwatch.stop();
  static void reset() => stopwatch.reset();
  static Duration get elapsed => stopwatch.elapsed;
}

abstract class StateManager<TState> {
  final _CubitWrapper<TState> _bloc;
  late DataConsumer<TState> _consumer;
  late DataProducer<TState> _producer;

  StateManager(TState initialState)
      : _bloc = _CubitWrapper<TState>(initialState);

  void pushNewState(TState Function(TState oldState) getNewState) {
    _bloc.pushNewState(() {
      var newState = getNewState(currentState);
      _producer.push(newState);
      return newState;
    });
  }

  TState get currentState => _bloc.state;

  BlocProvider getProvider() => BlocProvider<_CubitWrapper<TState>>(
      create: (BuildContext context) => _bloc);

  void initialize() {}

  void internalInitialize(ServiceCollection service) {
    var dataBinder = _StubDataBinder<TState>();
    _consumer = service.tryGet<DataConsumer<TState>>(() => dataBinder);
    _consumer.listen((data) => pushNewState((_) => data));

    _producer = service.tryGet<DataProducer<TState>>(() => dataBinder);
  }
}

class StateBuilder<S> extends StatelessWidget {
  final Widget Function(BuildContext context, S state) builder;

  const StateBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<_CubitWrapper<S>, S>(builder: builder);
}

class _StubDataBinder<T> implements DataProducer<T>, DataConsumer<T> {
  @override
  void listen(void Function(T data) onChange) {}

  @override
  void push(T data) {}
}

class _CubitWrapper<TState> extends Cubit<TState> {
  _CubitWrapper(super.initialState);

  void pushNewState(TState Function() getNewState) => emit(getNewState());
}
