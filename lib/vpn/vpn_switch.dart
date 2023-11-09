import 'package:lantern/vpn/vpn.dart';
import 'package:lantern/ffi.dart';

class VPNSwitch extends StatefulWidget {
  const VPNSwitch({super.key});

  @override
  State<VPNSwitch> createState() => _VPNSwitchState();
}

class _VPNSwitchState extends State<VPNSwitch> {
  // final adHelper = AdHelper();

  String vpnStatus = 'disconnected';

  @override
  void initState() {
    super.initState();
    // adHelper.loadAds();
  }

  bool isIdle(String vpnStatus) =>
      vpnStatus != 'connecting' && vpnStatus != 'disconnecting';

  Future<void> onSwitchTap(bool newValue) async {
    unawaited(HapticFeedback.lightImpact());
    if (isIdle(vpnStatus)) {
      if (Platform.isAndroid) {
        await vpnModel.switchVPN(newValue);
      } else if (Platform.isMacOS) {
        if (vpnStatus == 'connected') {
          await sysProxyOff();
        } else {
          await sysProxyOn();
        }
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

    setState(() {
      vpnStatus = newValue ? 'connected' : 'disconnected';
    });

  }

  @override
  Widget build(BuildContext context) {
    // Still working on ads feature
    return Transform.scale(
      scale: 2,
      child: FlutterSwitch(
          value: this.vpnStatus == 'connected' || this.vpnStatus == 'disconnecting',
          //value: true,
          activeColor: onSwitchColor,
          inactiveColor: offSwitchColor,
          onToggle: (bool newValue) => onSwitchTap(newValue),
        ),
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
