import 'package:flutter/material.dart';
import 'package:scale_framework/scale_framework.dart';

import 'module.dart';
import 'widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: ModuleSetup(
        featureModules: [CounterFeatureModule()],
        child: CountWidget(),
      ),
    );
  }
}
