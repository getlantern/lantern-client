import 'package:lantern/ad_helper.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/common_desktop.dart';
import 'package:lantern/vpn/vpn.dart';

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
      await TrayHandler.instance.setupTray(false);
    } else {
      sysProxyOn();
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
    if (isMobile()) {
      return sessionModel
          .shouldShowGoogleAds((context, isGoogleAdsEnable, child) {
        adHelper.loadAds(shouldShowGoogleAds: isGoogleAdsEnable);
        return Transform.scale(
            scale: 2,
            child: vpnModel.vpnStatus(
                (BuildContext context, String vpnStatus, Widget? child) {
              return FlutterSwitch(
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
            value: this.vpnStatus == 'connected' ||
                this.vpnStatus == 'disconnecting',
            //value: true,
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
