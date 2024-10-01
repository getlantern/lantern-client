import 'dart:isolate';

import 'package:lantern/common/ui/custom/internet_checker.dart';
import 'package:lantern/core/helpers/ad_helper.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/core/utils/common_desktop.dart';
import 'package:lantern/features/vpn/vpn.dart';
import 'package:lantern/features/vpn/vpn_notifier.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

SendPort? proxySendPort;

class VPNSwitch extends StatefulWidget {
  const VPNSwitch({super.key});

  @override
  State<VPNSwitch> createState() => _VPNSwitchState();
}

//implement this switch with loading implementation
//https://pub.dev/packages/animated_toggle_switch
class _VPNSwitchState extends State<VPNSwitch> {
  final adHelper = AdHelper();

  @override
  Widget build(BuildContext context) {
    final internetStatusProvider = context.watch<InternetStatusProvider>();
    final vpnNotifier = context.watch<VPNChangeNotifier>();
    if (isMobile()) {
      return sessionModel.shouldShowAds((context, provider, child) {
        adHelper.loadAds(provider: provider);
        return vpnModel.vpnStatus(context,
            (BuildContext context, String vpnStatus, Widget? child) {
          // Changes scale on mobile due to hit target
          return AdvancedSwitch(
            width: 150,
            height: 70,
            borderRadius: BorderRadius.circular(40),
            disabledOpacity: 1,
            enabled: (internetStatusProvider.isConnected &&
                !vpnNotifier.isFlashlightInitializedFailed),
            initialValue: vpnStatus == 'connected' ||
                vpnStatus == 'disconnecting' ||
                vpnStatus == 'connecting',
            activeColor: onSwitchColor,
            inactiveColor: (internetStatusProvider.isConnected &&
                    !vpnNotifier.isFlashlightInitializedFailed)
                ? offSwitchColor
                : grey3,
            onChanged: (newValue) =>
                vpnProcessForMobile(newValue, vpnStatus, provider.isNotEmpty),
          );
        });
      });
    } else {
      // This ui for desktop
      return ValueListenableBuilder<String>(
          valueListenable: vpnNotifier.vpnStatus,
          builder: (context, value, child) {
            return AdvancedSwitch(
              width: 160,
              height: 70,
              borderRadius: BorderRadius.circular(40),
              disabledOpacity: 1,
              enabled: (internetStatusProvider.isConnected &&
                  !vpnNotifier.isFlashlightInitializedFailed),
              initialValue: value == 'connected' || value == 'disconnecting',
              activeColor: onSwitchColor,
              inactiveColor: (internetStatusProvider.isConnected &&
                      !vpnNotifier.isFlashlightInitializedFailed)
                  ? offSwitchColor
                  : grey3,
              onChanged: (newValue) {
                final newStatus = newValue ? 'connected' : 'disconnected';
                vpnNotifier.vpnStatus.value = newStatus;
                LanternFFI.sendVpnStatus(newStatus);
              },
            );
          });
    }
  }

  bool isIdle(String vpnStatus) =>
      vpnStatus != 'connecting' && vpnStatus != 'disconnecting';

  Future<void> vpnProcessForMobile(
      bool newValue, String vpnStatus, bool userHasPermission) async {
    //Make sure user has permission all the permission
    //if ads is not ready then wait for at least 5 seconds and then show ads
    //if ads is ready then show ads immediately

    if (vpnStatus != 'connected' && userHasPermission) {
      if (!await adHelper.isAdsReadyToShow()) {
        await vpnModel.connectingDelay(newValue);
        await Future.delayed(const Duration(seconds: 5));
      }
    }

    await vpnModel.switchVPN(newValue);

    //add delayed to avoid flickering
    if (vpnStatus != 'connected') {
      Future.delayed(
        const Duration(seconds: 1),
        () async {
          await adHelper.showAds();
        },
      );
    }
  }
}
