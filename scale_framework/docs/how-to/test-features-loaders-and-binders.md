# Test features, loaders, and binders

Use this guide when you want framework-level confidence without booting a full app.

## Test a state-driven feature

Wrap the widget under test with `MaterialApp` and `ModuleSetup`:

```dart
Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ModuleSetup(
        featureModules: [CounterFeatureModule()],
        child: const CountWidget(),
      ),
    ),
  );
}
```

Then interact with the UI as usual:

```dart
await pumpApp(tester);
await tester.tap(find.byIcon(Icons.add));
await tester.pump();

expect(find.text('1'), findsOneWidget);
```

## Test a loader with a fake HTTP client

Register a mock client inside the feature module:

```dart
registry.addSingleton<http.Client>((_) => MockClient((request) async {
  return http.Response('some result', 200);
}));
```

Pump the app, then wait for the async request to finish:

```dart
await tester.pumpWidget(
  MaterialApp(
    home: ModuleSetup(
      featureModules: [TestFeatureModule()],
      child: const BffDataWidget(),
    ),
  ),
);

await tester.pump(const Duration(milliseconds: 5000));
expect(find.text('some result'), findsOneWidget);
```

## Test a binder

Drive the producer feature and assert on the consumer output:

```dart
await tester.tap(find.byType(FloatingActionButton));
await tester.pump(const Duration(milliseconds: 1));

expect(find.text('Some Brand'), findsOneWidget);
```

If your app composes isolated feature libraries, this is the fastest way to verify that the binder is registered in the right layer.
