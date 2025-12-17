import 'internal/debug_mode.dart';

export 'inversion_of_control/inversion_of_control.dart';
export 'state_management/state_management.dart';
export 'resources/resources.dart';
export 'resources/http/registry_extensions.dart';

class ScaleFramework {
  /// This enables debug mode.
  ///
  /// Makes the framework print:
  /// - state changes
  /// - bump the registered dependencies
  static void enableDebugMode() {
    scaleDebugPrint = print;
  }
}
