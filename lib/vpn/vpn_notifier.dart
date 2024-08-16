import '../common/common.dart';
import '../ffi.dart';

class VPNChangeNotifier extends ChangeNotifier {
  Timer? timer;
  bool isFlashlightInitialized = true;
  bool isFlashlightInitializedFailed = true;
  String flashlightState = 'fetching_configuration'.i18n;

  VPNChangeNotifier() {
    if (isMobile()) {
      initCallbackForMobile();
    } else {
      // TODO: change to call initCallbacks again
      isFlashlightInitialized = true;
      isFlashlightInitializedFailed = false;
      //initCallbacks();
    }
  }

  (bool, bool, bool) startUpInitCallBacks() {
    return LanternFFI.startUpInitCallBacks();
  }

  void initCallbacks() {
    if (timer != null) {
      return;
    }
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final result = startUpInitCallBacks();
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
      } else if (timer != null && timer!.tick >= 6) {
        // Timer has reached 6 seconds
        // Stop the timer and set isFlashlightInitialized to true
        print("flashlight fail initialized");
        isFlashlightInitialized = true;
        isFlashlightInitializedFailed = true;
        notifyListeners();
      }
    });
  }

  void initCallbackForMobile() {
    //Since IOS config is fetched from the on native side
    // We just need to make true for all
    if(Platform.isIOS){
      isFlashlightInitialized = true;
      isFlashlightInitializedFailed = false;
      notifyListeners();
      return;
    }

    if (timer != null) {
      return;
    }
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timer!.tick >= 6) {
        // Timer has reached 6 seconds
        // Stop the timer and set isFlashlightInitialized to true
        print("flashlight fail initialized");
        isFlashlightInitialized = true;
        isFlashlightInitializedFailed = true;
        notifyListeners();
      }
    });
    final configNotifier = sessionModel.pathValueNotifier('hasConfigFetched', false);
    final proxyNotifier = sessionModel.pathValueNotifier('hasProxyFetched', false);
    final successNotifier = sessionModel.pathValueNotifier('hasOnSuccess', false);

    updateStatus(bool proxy, bool config, bool success) {
      if (proxy || config) {
        flashlightState = 'fetching_configuration'.i18n;
      }
      if (proxy && config && !success) {
        flashlightState = 'establish_connection_to_server'.i18n;
      }
      notifyListeners();

      if (proxy && proxy && success) {
        // everything is initialized
        isFlashlightInitialized = true;
        isFlashlightInitializedFailed = false;
        timer?.cancel();
        print("flashlight initialized");
        notifyListeners();
      }
    }

    configNotifier.addListener(() {
      updateStatus(
          proxyNotifier.value!, configNotifier.value!, successNotifier.value!);
    });
    proxyNotifier.addListener(() {
      updateStatus(
          proxyNotifier.value!, configNotifier.value!, successNotifier.value!);
    });
    successNotifier.addListener(() {
      print("successNotifier Notfier ${successNotifier.value}");
      updateStatus(
          proxyNotifier.value!, configNotifier.value!, successNotifier.value!);
    });
  }

  @override
  void dispose() {
    if (timer?.isActive ?? false) {
      timer?.cancel();
    }
    isFlashlightInitialized = false;
    isFlashlightInitializedFailed = false;
    super.dispose();
  }
}
