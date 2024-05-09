import '../common/common.dart';
import '../ffi.dart';

class VPNChangeNotifier extends ChangeNotifier {
  Timer? timer;
  bool isFlashlightInitialized = false;
  bool isFlashlightInitializedFailed = false;
  String flashlightState = 'Fetching Configuration..'.i18n;

  VPNChangeNotifier() {
    initCallbacks();
  }

  void initCallbacks() {
    if (timer != null) {
      return;
    }
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final result = checkUICallbacks();
      if (!result.$1 || !result.$2) {
        flashlightState = 'fetching_configuration'.i18n;
      }
      if (result.$1 && result.$2 && !result.$3) {
        flashlightState = 'establish_connection_to_server'.i18n;
      }
      notifyListeners();
      if (result.$1 && result.$2 && result.$3) {
        // everything is initialized
        isFlashlightInitialized = true;
        isFlashlightInitializedFailed = false;
        print("flashlight initialized");
        notifyListeners();
        timer?.cancel();
      } else if (timer!.tick >= 6) {
        // Timer has reached 6 seconds
        // Stop the timer and set isFlashlightInitialized to true
        print("flashlight fail initialized");
        isFlashlightInitialized = true;
        isFlashlightInitializedFailed = true;
        notifyListeners();
      }
    });
  }
}
