# How Scale Framework is structured

Scale Framework is organized around one idea: **compose features before you render widgets**.

## Composition starts at app root

`ModuleSetup` is not only a convenience widget. It is the place where the framework:

1. builds the registry
2. registers framework HTTP support
3. lets feature modules register their own dependencies
4. initializes managers
5. exposes providers to the widget tree

That means the app decides composition once, near the root, instead of letting each screen invent its own setup rules.

## Feature libraries expose modules, not app structure

A feature library should usually export:

- one or more `FeatureModule`s
- widgets that consume framework state
- models, binders, and mappers that belong to that feature

It should **not** decide how the entire application is composed. That job belongs to the app or composition layer.

## State and services are registered differently on purpose

There are two main categories of dependency:

- services such as clients, mappers, and configuration objects
- state managers that must participate in widget rebuilding

`addSingleton(...)` handles the first category. `addGlobalStateManager(...)` handles the second.

That split is useful because state managers need provider wiring, while ordinary services do not.

## Loaders reuse the same composition model

`addLoader<T, TDto>(...)` looks higher level than `addGlobalStateManager(...)`, but it follows the same structure:

- register transport mapping
- register frontend mapping
- register request execution
- register state manager
- expose widget-facing rendering through `LoaderWidget<T>`

So loaders are not a separate subsystem bolted onto the framework. They are the same composition idea specialized for request-driven state.
