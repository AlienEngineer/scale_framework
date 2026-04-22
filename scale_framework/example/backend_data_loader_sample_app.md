# Backend data loader example

<table>
<tr>
<td>Load at init</td>
<td>Deferred initialization</td>
</tr>
<tr>
<td>

![](loader.gif)

</td>
<td>

![](delayed_loader.gif)

</td>
</tr>
</table>

This example is now documented in the main docs set:

- [Load data with `LoaderWidget`](../docs/tutorials/load-data-with-loader-widget.md)
- [Walk through the example apps](../docs/tutorials/walk-through-example-apps.md#loader-example)
- [Configure loaders and initial requests](../docs/how-to/configure-loaders-and-initial-requests.md)

## What to focus on

- `MapperOf<TDto>` parses raw response text
- `LoaderModelsFactory<T, TDto>` creates initial frontend state, initial request arguments, and frontend mapping
- `addLoader<T, TDto>(...)` registers request lifecycle for one frontend model type
- `LoaderWidget<T>` renders loading, loaded, and error UI
- `initializeOnAppStart: false` delays the request, but UI still starts in `loading()`
