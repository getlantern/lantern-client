import 'package:lantern/vpn/vpn.dart';
import 'package:lantern/ffi.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/common_desktop.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:lantern/main.dart';

class VPNSwitch extends StatefulWidget {
  const VPNSwitch({super.key});

  @override
  State<VPNSwitch> createState() => _VPNSwitchState();
}

class _VPNSwitchState extends State<VPNSwitch> with TrayListener {
  // final adHelper = AdHelper();

  String vpnStatus = 'disconnected';

  @override
  void initState() {
    if (isDesktop()) {
      trayManager.addListener(this);
    }
    super.initState();
    // adHelper.loadAds();
  }

  @override
  void dispose() {
    if (isDesktop()) {
      trayManager.removeListener(this);
    }
    super.dispose();
  }

  bool isIdle(String vpnStatus) =>
      vpnStatus != 'connecting' && vpnStatus != 'disconnecting';

  Future<void> onSwitchTap(bool newValue, String vpnStatus) async {
    unawaited(HapticFeedback.lightImpact());
    if (isIdle(vpnStatus)) {
      if (Platform.isAndroid) {
        await vpnModel.switchVPN(newValue);
      } else if (isDesktop()) {
        bool isConnected = vpnStatus == 'connected';
        String path = systemTrayIcon(!isConnected);
        if (isConnected) {
          sysProxyOff();
          await setupMenu(false);
        } else {
          sysProxyOn();
          await setupMenu(true);
        }
        await trayManager.setIcon(path);
      }
    }

    //add delayed to avoid flickering
    if (vpnStatus != 'connected') {
      Future.delayed(
        const Duration(seconds: 1),
        () async {
          // await adHelper.showAds();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Still working on ads feature
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
            onSwitchTap(newValue, vpnStatus);
            setState(() {
              this.vpnStatus = newValue ? 'connected' : 'disconnected';
            });
          },
        );
      }),
    );
    // return sessionModel
    //     .shouldShowGoogleAds((context, isGoogleAdsEnable, child) {
    //   return sessionModel.shouldShowCASAds((context, isCasAdsEnable, child) {
    //     // adHelper.loadAds(
    //     //     shouldShowGoogleAds: isGoogleAdsEnable,
    //     //     shouldShowCASAds: isCasAdsEnable);
    //     return Transform.scale(
    //         scale: 2,
    //         child: vpnModel.vpnStatus(
    //             (BuildContext context, String vpnStatus, Widget? child) {
    //           return FlutterSwitch(
    //             value: vpnStatus == 'connected' || vpnStatus == 'disconnecting',
    //             activeColor: onSwitchColor,
    //             inactiveColor: offSwitchColor,
    //             onToggle: (bool newValue) => onSwitchTap(newValue, vpnStatus),
    //           );
    //         }));
    //   });
    // });
  }
}
