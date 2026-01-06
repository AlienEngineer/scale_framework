import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scale_framework/scale_framework.dart';

void main() {
  testWidgets('producing a vehicle pushes brand to consumer', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ModuleSetup(
        featureModules: [TestFeatureModule()],
        child: TestWidget(),
      ),
    ));
    await tester.pump(Duration(milliseconds: 1));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(Duration(milliseconds: 1));

    expect(find.text('Some Brand'), findsOneWidget);
  });
}

class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StateBuilder<Brand>(builder: (context, state) => Text(state.brand)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context
            .getStateManager<VehicleStateManager>()
            .loadVehicle('Some Brand'),
      ),
    );
  }
}

class VehicleStateManager extends StateManager<Vehicle> {
  VehicleStateManager() : super(Vehicle(''));

  void loadVehicle(String brand) => pushNewState((_) => Vehicle(brand));
}

class BrandStateManager extends StateManager<Brand> {
  BrandStateManager() : super(Brand(''));
}

class TestFeatureModule implements FeatureModule {
  @override
  void setup(PublicRegistry registry) {
    registry
        .addBinder<Vehicle>()
        .addConsumer<Brand>((data) => Brand(data.brand));

    registry.addGlobalStateManager((_) => VehicleStateManager());
    registry.addGlobalStateManager((_) => BrandStateManager());
  }
}

class Brand {
  final String brand;
  const Brand(this.brand);
}

class Vehicle {
  final String brand;
  const Vehicle(this.brand);
}
