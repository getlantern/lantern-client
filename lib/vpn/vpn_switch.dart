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

class _VPNSwitchState extends State<VPNSwitch> {
  final adHelper = AdHelper();
  String vpnStatus = 'disconnected';

  bool isIdle(String vpnStatus) =>
      vpnStatus != 'connecting' && vpnStatus != 'disconnecting';

  Future<void> vpnProcessForDesktop() async {
    bool isConnected = vpnStatus == 'connected';
    if (isConnected) {
      sysProxyOff();
      await setupMenu(false);
    } else {
      sysProxyOn();
      await setupMenu(true);
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
      return sessionModel
          .shouldShowGoogleAds((context, isGoogleAdsEnable, child) {
        adHelper.loadAds(shouldShowGoogleAds: isGoogleAdsEnable);
        return Transform.scale(
            scale: 2,
            child: vpnModel.vpnStatus(
                (BuildContext context, String vpnStatus, Widget? child) {
              return FlutterSwitch(
                disabled: (!internetStatusProvider.isConnected||vpnNotifier.isFlashlightInitializedFailed),
                value: vpnStatus == 'connected' || vpnStatus == 'disconnecting',
                activeColor: onSwitchColor,
                inactiveColor: offSwitchColor,
                onToggle: (bool newValue) =>
                    vpnProcessForMobile(newValue, vpnStatus, isGoogleAdsEnable),
              );
            }));
      });
    } else {
      // This ui for desktop
      return Transform.scale(
        scale: 2,
        child: vpnModel
            .vpnStatus((BuildContext context, String vpnStatus, Widget? child) {
          this.vpnStatus = vpnStatus;
          return FlutterSwitch(
            disabled: (!internetStatusProvider.isConnected||vpnNotifier.isFlashlightInitializedFailed),
            value: this.vpnStatus == 'connected' ||
                this.vpnStatus == 'disconnecting',
            activeColor: onSwitchColor,
            inactiveColor: offSwitchColor,
            onToggle: (bool newValue) {
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
