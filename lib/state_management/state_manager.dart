import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StateManager<TState> {
  final CubitWrapper<TState> _bloc;

  StateManager(TState initialState)
      : _bloc = CubitWrapper<TState>(initialState);

  void pushNewState(TState Function(TState oldState) getNewState) =>
      _bloc.pushNewState(() => getNewState(_currentState));

  TState get _currentState => _bloc.state;

  BlocProvider<CubitWrapper<TState>> getProvider() =>
      BlocProvider(create: (BuildContext context) => _bloc);
}

class CubitWrapper<TState> extends Cubit<TState> {
  CubitWrapper(super.initialState);

  void pushNewState(TState Function() getNewState) => emit(getNewState());
}
