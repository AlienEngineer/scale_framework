import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scale_framework/scale_framework.dart';

class Watch {
  static var stopWatch = Stopwatch();
}

class StateBuilder<S> extends StatelessWidget {
  final Widget Function(BuildContext context, S state) builder;

  const StateBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) => BlocBuilder<CubitWrapper<S>, S>(
        builder: (context, state) {
          Watch.stopWatch.start();
          var result = builder(context, state);

          Watch.stopWatch.stop();
          print("${Watch.stopWatch.elapsed.inMicroseconds}");
          return result;
        },
      );
}
