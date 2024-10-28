import 'dart:ui' as ui;

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:lantern/common/ui/custom/internet_checker.dart';
import 'package:lantern/core/helpers/ad_helper.dart';
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
      return CustomAnimatedToggleSwitch<String>(
        current: vpnNotifier.vpnStatus.value,
        values: const ['disconnected', 'connected'],
        iconBuilder: (context, local, global) => const SizedBox(),
        height: 72,
        spacing: 28.0,
        active: (internetStatusProvider.isConnected &&
            !vpnNotifier.isFlashlightInitializedFailed),
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
          if (vpnNotifier.vpnStatus.value == 'connected') {
            vpnProcessForDesktop('disconnected');
          } else {
            vpnProcessForDesktop('connected');
          }
        },
      );
    }
  }

  Color getWrapperColor(bool vpnStatus, bool internetConnected,
      bool isFlashlightInitializedFailed) {
    if (internetConnected && !isFlashlightInitializedFailed) {
      if (vpnStatus) {
        return onSwitchColor;
      }
      return offSwitchColor;
    }
    return grey3;
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

  Future<void> vpnProcessForDesktop(String vpnStatus) async {
    final vpnNotifier = Provider.of<VPNChangeNotifier>(context, listen: false);
    try {
      await LanternFFI.sendVpnStatus(vpnStatus);
      vpnNotifier.updateVpnStatus(vpnStatus);
    } catch (e) {
      await vpnNotifier.updateVpnStatus('disconnected');
      showSnackbar(context: context, content: e.localizedDescription);
      mainLogger.e("Error while sending vpn status: $e");
    }
  }
}
