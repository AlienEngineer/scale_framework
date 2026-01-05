import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scale_framework/scale_framework.dart';

abstract class StateManager<TState> {
  final CubitWrapper<TState> _bloc;
  late DataConsumer<TState> _consumer;
  late DataProducer<TState> _producer;

  StateManager(TState initialState)
      : _bloc = CubitWrapper<TState>(initialState);

  void pushNewState(TState Function(TState oldState) getNewState) =>
      _bloc.pushNewState(() {
        var newState = getNewState(_currentState);
        _producer.push(newState);
        return newState;
      });

  TState get _currentState => _bloc.state;

  BlocProvider<CubitWrapper<TState>> getProvider() =>
      BlocProvider(create: (BuildContext context) => _bloc);

  void initialize() {}

  void internalInitialize(ServiceCollection service) {
    var dataBinder = StubDataBinder<TState>();
    _consumer = service.tryGet<DataConsumer<TState>>(() => dataBinder);
    _consumer.listen((data) => pushNewState((_) => data));

    _producer = service.tryGet<DataProducer<TState>>(() => dataBinder);
  }
}

class StubDataBinder<T> implements DataProducer<T>, DataConsumer<T> {
  @override
  void listen(void Function(T data) onChange) {}

  @override
  void push(T data) {}
}

class CubitWrapper<TState> extends Cubit<TState> {
  CubitWrapper(super.initialState);

  void pushNewState(TState Function() getNewState) => emit(getNewState());
}
