# How state, loaders, and binders work together

Scale Framework has three related data-flow patterns.

## 1. State manager flow

Use `StateManager<T>` when data belongs to one feature and changes through domain actions.

Flow:

1. widget calls a manager method
2. manager computes next state with `pushNewState(...)`
3. `StateBuilder<T>` rebuilds

This is the base pattern.

## 2. Loader flow

Use a loader when the feature state comes from a request lifecycle.

Flow:

1. feature registers `addLoader<T, TDto>(...)`
2. request runs through HTTP interceptors
3. response string maps to `TDto`
4. loader factory maps `TDto` to frontend model `T`
5. `LoaderWidget<T>` renders loading, loaded, or error UI

This is state manager flow plus request orchestration.

## 3. Binder flow

Use a binder when one produced type should become another consumed type.

Flow:

1. a manager or explicit producer pushes `T1`
2. binder maps `T1 -> T2`
3. consumer or `StateManager<T2>` receives the mapped value

This is how independently built features can still participate in one application flow.

## Mental model

Think of the framework like this:

- state managers own feature state
- loaders own request-backed state
- binders move meaning across feature boundaries

All three rely on typed registration and app-level composition. That shared structure is why the framework stays predictable even when a feature grows from a counter into several backend-backed flows.
