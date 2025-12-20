import 'package:scale_framework/scale_framework.dart';

class CounterStateManager extends StateManager<int> {
  CounterStateManager() : super(0);

  void increment() => pushNewState((oldState) => oldState + 1);
}
