# Counter example

![](counter.gif)

This example is now documented in the main docs set:

- [Build your first feature](../docs/tutorials/build-your-first-feature.md)
- [Walk through the example apps](../docs/tutorials/walk-through-example-apps.md#counter-example)

## What to focus on

- one `StateManager<int>` owns the counter value
- one `FeatureModule` registers the manager
- one `StateBuilder<int>` renders current value
- widgets update state through `context.getStateManager<CounterStateManager>()`
