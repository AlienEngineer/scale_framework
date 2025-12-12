// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scale_framework/scale_framework.dart';

class TestStateManager extends StateManager<int> {
  TestStateManager() : super(0);

  void increment() => pushNewState((oldState) => oldState + 1);

  @override
  void initialize() {}
}

class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StateBuilder<TestStateManager, int>(
        builder: (context, count) => Center(child: Text('$count')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.getStateManager<TestStateManager>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TestFeatureModule extends FeatureModule {
  @override
  void setup(PublicRegistry registry) {
    registry.addGlobalStateManager(TestStateManager());
  }
}

void main() {
  testWidgets('On render display initial state which is 0',
      (WidgetTester tester) async {
    await pumpApp(tester);

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('After tapping floating button increments state to 1',
      (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter starts at 0.
    expect(find.text('1'), findsOneWidget);
  });
  testWidgets('After tapping twice floating button increments state to 2',
      (WidgetTester tester) async {
    await pumpAppWithCluster(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter starts at 0.
    expect(find.text('2'), findsOneWidget);
  });
}

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    home: ModuleSetup(
      registry: FeatureModulesRegistry(
        featureModules: [TestFeatureModule()],
      ),
      child: TestWidget(),
    ),
  ));
}

Future<void> pumpAppWithCluster(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    home: ModuleSetup(
      registry: FeatureModulesRegistry(
        featureClusters: [TestCluster()],
      ),
      child: TestWidget(),
    ),
  ));
}

class TestCluster implements FeatureCluster {
  @override
  void setup(ModuleRegistry registry) {
    registry.addModule((_) => TestFeatureModule());
  }
}
