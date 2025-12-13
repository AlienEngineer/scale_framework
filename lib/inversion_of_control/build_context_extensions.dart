import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:scale_framework/scale_framework.dart';

extension BuildContextExtensions on BuildContext {
  T getStateManager<T>() => read<StateManagerRegistry>().getManager<T>();
  LoaderStateManager getLoaderFor<T>() =>
      read<StateManagerRegistry>().getLoaderFor<T>();
}
