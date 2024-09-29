import 'package:lantern/core/service/lantern_ffi_service.dart';
import 'package:lantern/core/utils/common.dart';

class VPNChangeNotifier with ChangeNotifier {
  Timer? timer;
  final ValueNotifier<String> _vpnStatus =
      ValueNotifier<String>('disconnected');

  ValueNotifier<String> get vpnStatus => _vpnStatus;
  bool isFlashlightInitialized = false;
  bool isFlashlightInitializedFailed = false;
  String flashlightState = 'fetching_configuration'.i18n;

  VPNChangeNotifier() {
    if (isMobile()) {
      initCallbackForMobile();
    } else {
      initCallbacksDesktop();
    }
  }

  bool isConnected() => vpnStatus.value == 'connected';

  void toggleConnection() {
    if (isConnected()) {
      LanternFFI.sysProxyOff();
      _vpnStatus.value = 'disconnected';
    } else {
      LanternFFI.sysProxyOn();
      _vpnStatus.value = 'connected';
    }
    notifyListeners();
  }

  void initCallbacksDesktop() {
    if (timer != null) {
      return;
    }
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final configNotifier = sessionModel.configNotifier.value;
      if (configNotifier == null) {
        return;
      }
      updateStatus(
          configNotifier.fetchedProxiesConfig,
          configNotifier.fetchedGlobalConfig,
          configNotifier.hasSucceedingProxy);
    });
  }

  void initCallbackForMobile() {
    //Since IOS config is fetched from the on native side
    // We just need to make true for all
    if (Platform.isIOS) {
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
    final configNotifier =
        sessionModel.pathValueNotifier('hasConfigFetched', false);
    final proxyNotifier =
        sessionModel.pathValueNotifier('hasProxyFetched', false);
    final successNotifier =
        sessionModel.pathValueNotifier('hasOnSuccess', false);

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

  void updateStatus(bool proxy, bool config, bool success) {
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
