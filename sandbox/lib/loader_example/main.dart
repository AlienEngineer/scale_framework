import 'package:flutter/material.dart';
import 'package:scale_framework/scale_framework.dart';

import 'module.dart';
import 'widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: ModuleSetup(
        featureModules: [TestFeatureModule(1)],
        child: MyWidget(),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const BffDataTestWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.refresh<BffData>({'id': 1});
        },
        child: Icon(Icons.cloud_download),
      ),
    );
  }
}
