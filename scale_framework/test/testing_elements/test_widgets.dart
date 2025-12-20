import 'package:flutter/widgets.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) => const Placeholder();
}

class LoadedWidget extends StatelessWidget {
  final String data;
  const LoadedWidget(this.data, {super.key});

  @override
  Widget build(BuildContext context) => Text(data);
}

class FailureWidget extends StatelessWidget {
  const FailureWidget({super.key});

  @override
  Widget build(BuildContext context) => const Placeholder();
}
