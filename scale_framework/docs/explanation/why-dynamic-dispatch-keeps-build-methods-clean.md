# Why dynamic dispatch keeps build methods clean

The framework leans toward dynamic dispatch because state-driven UI is easier to grow than giant conditional build methods.

## What problem this avoids

Without a clear rendering pattern, build methods often turn into this:

- fetch some state
- inspect several booleans
- branch across loading, loaded, error, empty, and retry cases
- keep growing every time the feature gets one more state

That style makes the widget own too many decisions.

## What the framework prefers instead

Scale Framework pushes rendering decisions closer to the state boundary:

- `StateBuilder<T>` gives the widget one typed state value to render
- `LoaderWidget<T>` splits rendering into `loading`, `loaded`, and `onError`

That is dynamic dispatch in practice: choose the render path from state and type, instead of keeping one large conditional tree in `build(...)`.

## Why this matters for feature libraries

Independent feature libraries need boundaries that stay readable as the feature grows. If one widget owns every render branch, the feature becomes harder to reuse and harder to explain.

By separating render paths:

- each UI state gets a named method
- state transitions stay in managers
- widgets stay focused on presenting the current state

This does not remove all branching from Flutter code. It moves the important branching into explicit, reusable framework patterns.
