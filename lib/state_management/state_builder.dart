import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scale_framework/scale_framework.dart';

class StateBuilder<T extends StateManager<S>, S> extends StatelessWidget {
  final Widget Function(BuildContext context, S state) builder;

  const StateBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CubitWrapper<S>, S>(builder: builder);
}
