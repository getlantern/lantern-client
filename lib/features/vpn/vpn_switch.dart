import 'dart:ui' as ui;

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:lantern/common/ui/custom/internet_checker.dart';
import 'package:lantern/core/service/ad_service.dart';
import 'package:lantern/core/service/survey_service.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/core/utils/common_desktop.dart';
import 'package:lantern/features/vpn/vpn.dart';
import 'package:lantern/features/vpn/vpn_notifier.dart';

class VPNSwitch extends StatefulWidget {
  const VPNSwitch({super.key});

  @override
  State<VPNSwitch> createState() => _VPNSwitchState();
}

//implement this switch with loading implementation
//https://pub.dev/packages/animated_toggle_switch
class _VPNSwitchState extends State<VPNSwitch> {
  final adHelper = sl.get<AdsService>();

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
            enabled:
                isSwitchEnabled(vpnStatus, vpnNotifier, internetStatusProvider),
            initialValue: vpnStatus == VpnStatus.connected.name ||
                vpnStatus == VpnStatus.disconnecting.name ||
                vpnStatus == VpnStatus.connecting.name,
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
      return CustomAnimatedToggleSwitch<String>(
        current: vpnNotifier.vpnStatus.value,
        values: [VpnStatus.disconnected.name, VpnStatus.connected.name],
        iconBuilder: (context, local, global) => const SizedBox(),
        height: 72,
        spacing: 28.0,
        active: isSwitchEnabled(
            vpnNotifier.vpnStatus.value, vpnNotifier, internetStatusProvider),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        indicatorSize: const ui.Size(60, 60),
        animationDuration: const Duration(milliseconds: 350),
        animationCurve: Curves.easeIn,
        foregroundIndicatorBuilder: (context, global) {
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (internetStatusProvider.isConnected &&
                      !vpnNotifier.isFlashlightInitializedFailed)
                  ? grey3
                  : Colors.white,
              shape: BoxShape.circle,
            ),
          );
        },
        wrapperBuilder: (context, global, child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: getWrapperColor(
                  vpnNotifier.isConnected(),
                  internetStatusProvider.isConnected,
                  vpnNotifier.isFlashlightInitializedFailed),
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: child,
          );
        },
        onChanged: (newValue) {},
        onTap: (props) {
          if (vpnNotifier.vpnStatus.value == VpnStatus.connected.name) {
            vpnProcessForDesktop(VpnStatus.disconnected.name);
          } else {
            vpnProcessForDesktop(VpnStatus.connected.name);
          }
        },
      );
    }
  }

  Color getWrapperColor(bool vpnConnected, bool internetConnected,
      bool isFlashlightInitializedFailed) {
    if (vpnConnected) {
      return onSwitchColor;
    }
    if (internetConnected && !isFlashlightInitializedFailed) {
      if (vpnConnected) {
        return onSwitchColor;
      }
      return offSwitchColor;
    }
    return grey3;
  }

  bool isSwitchEnabled(String vpnStatus, VPNChangeNotifier vpnNotifier,
      InternetStatusProvider internetStatusProvider) {
    if (vpnStatus == VpnStatus.connected.name) {
      return true;
    }
    return internetStatusProvider.isConnected &&
        !vpnNotifier.isFlashlightInitializedFailed;
  }

  Future<void> vpnProcessForMobile(
      bool newValue, String vpnStatus, bool userHasPermission) async {
    //Make sure user has permission all the permission
    //if ads is not ready then wait for at least 5 seconds and then show ads
    //if ads is ready then show ads immediately

    if (vpnStatus != VpnStatus.connected.name && userHasPermission) {
      if (!await adHelper.isAdsReadyToShow()) {
        await vpnModel.connectingDelay(newValue);
        await Future.delayed(const Duration(seconds: 5));
      }
    }

    await vpnModel.switchVPN(newValue);

    //add delayed to avoid flickering
    if (vpnStatus != VpnStatus.connected.name) {
      Future.delayed(
        const Duration(seconds: 1),
        () async {
          await adHelper.showAds();
        },
      );
    }

    if (vpnStatus == VpnStatus.disconnected.name) {
      // Update survey count
      sl.get<SurveyService>().incrementVpnConnectCount();
    }
  }

  Future<void> vpnProcessForDesktop(String vpnStatus) async {
    final vpnNotifier = context.watch<VPNChangeNotifier>();
    try {
      await LanternFFI.sendVpnStatus(vpnStatus);
      vpnNotifier.updateVpnStatus(vpnStatus);
      if (vpnStatus == VpnStatus.disconnected.name) {
        // Update survey count
        sl.get<SurveyService>().incrementVpnConnectCount();
      }
    } catch (e) {
      await vpnNotifier.updateVpnStatus(VpnStatus.disconnected.name);
      showSnackbar(context: context, content: e.localizedDescription);
      mainLogger.e("Error while sending vpn status: $e");
    }
  }
}
