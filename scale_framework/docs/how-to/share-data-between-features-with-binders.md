# Share data between features with binders

Use this guide when one feature produces data that another feature should consume.

## Use the short binder form

```dart
registry.addBinder<Vehicle>().addConsumer((vehicle) => Brand(vehicle.brand));
```

This means:

- a producer emits `Vehicle`
- the binder maps `Vehicle` into `Brand`
- any `StateManager<Brand>` registered in the app can receive the mapped value

## Use a dedicated binder for more complex mapping

```dart
class VehicleToBrandBinder extends DataBinder<Vehicle, Brand> {
  @override
  Brand map(Vehicle data) => Brand(data.brand);
}

registry.addDataBinder(() => VehicleToBrandBinder());
```

Use a dedicated `DataBinder<T1, T2>` when mapping needs naming, tests, or more logic than one inline lambda.

## Where binders should live

If two independent feature libraries must stay isolated, keep the binder in the app or composition layer, not inside either feature package.

That keeps the rule intact:

- feature libraries depend on `scale_framework`
- app composes features
- framework mechanisms carry data across feature boundaries

## Example flow

```dart
class VehicleStateManager extends StateManager<Vehicle> {
  VehicleStateManager() : super(Vehicle(''));

  void loadVehicle(String brand) => pushNewState((_) => Vehicle(brand));
}

class BrandStateManager extends StateManager<Brand> {
  BrandStateManager() : super(Brand(''));
}
```

When `VehicleStateManager` pushes a `Vehicle`, the binder maps it into `Brand`, and `BrandStateManager` receives the mapped value.
