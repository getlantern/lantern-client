import 'package:lantern/vpn/vpn.dart';

class VPNSwitch extends StatefulWidget {
  const VPNSwitch({super.key});

  @override
  State<VPNSwitch> createState() => _VPNSwitchState();
}

class _VPNSwitchState extends State<VPNSwitch> {
  // final adHelper = AdHelper();

  @override
  void initState() {
    super.initState();
    // adHelper.loadAds();
  }

  bool isIdle(String vpnStatus) =>
      vpnStatus != 'connecting' && vpnStatus != 'disconnecting';

  Future<void> onSwitchTap(bool newValue, String vpnStatus) async {
    unawaited(HapticFeedback.lightImpact());

    if (isIdle(vpnStatus)) {
      await vpnModel.switchVPN(newValue);
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
        return FlutterSwitch(
          value: vpnStatus == 'connected' || vpnStatus == 'disconnecting',
          activeColor: onSwitchColor,
          inactiveColor: offSwitchColor,
          onToggle: (bool newValue) => onSwitchTap(newValue, vpnStatus),
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
