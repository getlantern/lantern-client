import 'package:lantern/ad_helper.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/common_desktop.dart';
import 'package:lantern/vpn/vpn.dart';
import 'package:lantern/vpn/vpn_notifier.dart';

import '../common/ui/custom/internet_checker.dart';

class VPNSwitch extends StatefulWidget {
  const VPNSwitch({super.key});

  @override
  State<VPNSwitch> createState() => _VPNSwitchState();
}

//implement this switch with loading implementation
//https://pub.dev/packages/animated_toggle_switch
class _VPNSwitchState extends State<VPNSwitch> {
  final adHelper = AdHelper();
  String vpnStatus = 'disconnected';

  bool isIdle(String vpnStatus) =>
      vpnStatus != 'connecting' && vpnStatus != 'disconnecting';

  Future<void> vpnProcessForDesktop() async {
    bool isConnected = vpnStatus == 'connected';
    if (isConnected) {
      LanternFFI.sysProxyOff();
      await TrayHandler.instance.setupTray(false);
    } else {
      LanternFFI.sysProxyOn();
      await TrayHandler.instance.setupTray(true);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final internetStatusProvider = context.watch<InternetStatusProvider>();
    final vpnNotifier = context.watch<VPNChangeNotifier>();
    if (isMobile()) {
      return sessionModel.shouldShowAds((context, provider, child) {
        //Since we don't have feature flag on ios at the moment
        // disable ads'
        adHelper.loadAds(provider: provider);

        return vpnModel
            .vpnStatus((BuildContext context, String vpnStatus, Widget? child) {
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
      return Transform.scale(
        scale: 2.5,
        child: vpnModel
            .vpnStatus((BuildContext context, String vpnStatus, Widget? child) {
          this.vpnStatus = vpnStatus;
          return AdvancedSwitch(
            width: 60,
            disabledOpacity: 1,
            enabled: (internetStatusProvider.isConnected &&
                !vpnNotifier.isFlashlightInitializedFailed),
            initialValue: this.vpnStatus == 'connected' ||
                this.vpnStatus == 'disconnecting',
            activeColor: onSwitchColor,
            inactiveColor: (internetStatusProvider.isConnected &&
                    !vpnNotifier.isFlashlightInitializedFailed)
                ? offSwitchColor
                : grey3,
            onChanged: (newValue) {
              vpnProcessForDesktop();
              setState(() {
                this.vpnStatus = newValue ? 'connected' : 'disconnected';
              });
            },
          );
        }),
      );
    }
  }
}
