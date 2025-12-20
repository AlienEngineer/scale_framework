import 'package:flutter/material.dart';
import 'package:scale_framework/scale_framework.dart';

import 'state_manager.dart';

class CountWidget extends StatelessWidget {
  const CountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // StateBuilder reacts to any state change of int.
      body: StateBuilder<int>(
        builder: (context, count) => Center(child: Text('$count')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => increment(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Acquires the CounterStateManager
  // call increment method on that manager
  void increment(BuildContext context) =>
      context.getStateManager<CounterStateManager>().increment();
}
