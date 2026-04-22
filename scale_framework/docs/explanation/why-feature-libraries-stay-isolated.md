# Why feature libraries stay isolated

Scale Framework works best when feature libraries depend on `scale_framework`, not on each other.

## Why isolation matters

Direct feature-to-feature dependencies create hidden coupling:

- one feature starts knowing another feature's internal types
- reuse gets harder because the feature is no longer self-contained
- app composition moves out of the app layer and into feature packages

That is the opposite of what the framework is trying to give you.

## What belongs to a feature library

A feature library should own:

- its modules
- its state managers
- its widgets
- its request mappers and loader factories
- its internal models and logic

## What belongs to the app or composition layer

The app layer should own:

- which features are present
- how modules are grouped into clusters
- which binders connect one feature's produced data to another feature's consumed data
- global HTTP values and app-wide interceptors

This is where cross-feature knowledge belongs, because it is composition knowledge.

## How features still communicate

Isolation does not mean features can never influence each other. It means the influence should move through framework contracts:

- `StateManager<T>` produces typed state
- `DataBinder<T1, T2>` maps one type into another
- `context.push(...)` forwards produced events
- loaders can refresh from mapped notifications

When a binder needs types from two feature libraries, keep that binder in the app layer that already knows both packages.

That preserves independence without blocking collaboration.
