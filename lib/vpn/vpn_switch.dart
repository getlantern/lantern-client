import 'package:lantern/ad_helper.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/common_desktop.dart';
import 'package:lantern/vpn/vpn.dart';
import 'package:tray_manager/tray_manager.dart';

import '../ad_helper.dart';

class VPNSwitch extends StatefulWidget {
  const VPNSwitch({super.key});

  @override
  State<VPNSwitch> createState() => _VPNSwitchState();
}

class _VPNSwitchState extends State<VPNSwitch> with TrayListener {
  //final adHelper = AdHelper();
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
      //if (!await adHelper.isAdsReadyToShow()) {
        await vpnModel.connectingDelay(newValue);
        await Future.delayed(const Duration(seconds: 5));
      //}
    }

    await vpnModel.switchVPN(newValue);

    //add delayed to avoid flickering
    if (vpnStatus != 'connected') {
      Future.delayed(
        const Duration(seconds: 1),
        () async {
          //await adHelper.showAds();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Transform.scale(
      scale: 2,
      child: vpnModel
          .vpnStatus((BuildContext context, String vpnStatus, Widget? child) {
        return FlutterSwitch(
          value: vpnStatus == 'connected' || vpnStatus == 'disconnecting',
          activeColor: onSwitchColor,
          inactiveColor: offSwitchColor,
          onToggle: (bool newValue) => vpnProcessForMobile(newValue, vpnStatus, true),
        );
      }),
    );
    /*if (isMobile()) {
      return sessionModel
          .shouldShowGoogleAds((context, isGoogleAdsEnable, child) {
        return sessionModel.shouldShowCASAds((context, isCasAdsEnable, child) {
          //adHelper.loadAds(
          //    shouldShowGoogleAds: isGoogleAdsEnable,
          //    shouldShowCASAds: isCasAdsEnable);
          return Transform.scale(
              scale: 2,
              child: vpnModel.vpnStatus(
                  (BuildContext context, String vpnStatus, Widget? child) {
                return FlutterSwitch(
                  value:
                      vpnStatus == 'connected' || vpnStatus == 'disconnecting',
                  activeColor: onSwitchColor,
                  inactiveColor: offSwitchColor,
                  onToggle: (bool newValue) {
                    vpnProcessForMobile(newValue,
                      vpnStatus, (isGoogleAdsEnable || isCasAdsEnable));
                    setState(() {
                      this.vpnStatus = newValue ? 'connected' : 'disconnected';
                    });
                  },
                );
              }));
        });
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
    }*/
  }
}
