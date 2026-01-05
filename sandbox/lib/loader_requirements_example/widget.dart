import 'package:flutter/material.dart';
import 'package:scale_framework/scale_framework.dart';

class BffData {
  final String data;

  BffData({this.data = ""});
}

class BffDataTestWidget extends LoaderWidget<BffData> {
  const BffDataTestWidget({super.key});

  @override
  Widget loaded(BuildContext context, BffData data) =>
      Text(data.data, style: Theme.of(context).textTheme.headlineMedium);

  @override
  Widget loading(BuildContext context) =>
      Text('loading', style: Theme.of(context).textTheme.headlineMedium);

  @override
  Widget onError(BuildContext context, BffData data) =>
      Text('failed', style: Theme.of(context).textTheme.headlineMedium);
}
