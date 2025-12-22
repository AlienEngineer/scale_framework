## Basic Counter App

![](counter.gif)

To create the simple counter app we need 3 parts: A StateManager, A FeatureModule and the actual Widget.

### State Manager

```dart
class CounterStateManager extends StateManager<int> {
  CounterStateManager() : super(0);

  void increment() => pushNewState((oldState) => oldState + 1);
}
```

### Feature Module

```dart
class CounterFeatureModule extends FeatureModule {
  @override
  void setup(PublicRegistry registry) {
    registry.addGlobalStateManager(CounterStateManager());
  }
}
```


### Widget

```dart
class CountWidget extends StatelessWidget {
  const CountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StateBuilder<int>(
        builder: (context, count) => Center(child: Text('$count')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.getStateManager<CounterStateManager>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Putting it all together

```dart
MaterialApp(
  home: ModuleSetup(
    featureModules: [CounterFeatureModule()],
    child: CountWidget(),
  ),
)
```