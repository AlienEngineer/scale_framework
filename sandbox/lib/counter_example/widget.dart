import 'package:flutter/material.dart';
import 'package:scale_framework/scale_framework.dart';

import 'state_manager.dart';

class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // StateBuilder reacts to any state change of int.
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("This is a test"),
                    onChange<int>(
                      (v) => ElevatedButton(
                        onPressed: () => increment(context),
                        child: Text('$v'),
                      ),
                    ),
                    onChange<int>(
                      (v) => ElevatedButton(
                        onLongPress: () {
                          for (var i = 0; i < 10; i++) {
                            decrement(context);
                          }
                        },
                        onPressed: () => decrement(context),
                        child: Text('$v'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: onChange<int>((v) => Text('$v')),
            ),
          ],
        ),
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
      context.getStateManager<IntStateManager>().increment();

  void decrement(BuildContext context) =>
      context.getStateManager<IntStateManager>().decrement();
}

class UpdatableText<TState> extends UpdatableWidget<TState> {
  final String Function(TState) convert;
  const UpdatableText(this.convert, {super.key});

  @override
  Widget onChange(BuildContext ctx, TState state) => Text(convert(state));
}
