import 'internal/debug_mode.dart';

export 'inversion_of_control/inversion_of_control.dart';
export 'state_management/state_management.dart';
export 'resources/resources.dart';

class ScaleFramework {
  /// This flag enables/disables debug mode.
  ///
  /// Makes the framework print:
  /// - state changes
  static void enableDebugMode() {
    scaleDebugPrint = print;
  }
}
