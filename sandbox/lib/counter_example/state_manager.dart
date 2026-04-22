import 'dart:async';

import 'package:scale_framework/scale_framework.dart';

class IntStateManager extends StateManager<int> {
  IntStateManager() : super(0);

  @override
  void initialize() {
    Timer.periodic(Duration(milliseconds: 300), (timer) => increment());
  }

  void increment() => pushNewState((oldState) => oldState + 1);

  void decrement() => pushNewState((oldState) => oldState - 1);
}
