import 'package:lantern/ad_helper.dart';
import 'package:lantern/vpn/vpn.dart';

class VPNSwitch extends StatefulWidget {
  const VPNSwitch({super.key});

  @override
  State<VPNSwitch> createState() => _VPNSwitchState();
}

class _VPNSwitchState extends State<VPNSwitch> {
  final adHelper = AdHelper();

  bool isIdle(String vpnStatus) =>
      vpnStatus != 'connecting' && vpnStatus != 'disconnecting';

  Future<void> onSwitchTap(
      bool newValue, String vpnStatus, bool userHasPermission) async {
    unawaited(HapticFeedback.lightImpact());
    // Make sure user has permission all the permission
    // if ads is not ready then wait for at least 5 seconds and then show ads
    // if ads is ready then show ads immediately

    if (vpnStatus != 'connected' && userHasPermission) {
      if (!await adHelper.isAdsReadyToShow()) {
        await vpnModel.connectingDelay(newValue);
        await Future.delayed(const Duration(seconds: 5));
      }
    }
    if (isIdle(vpnStatus)) {
      await vpnModel.switchVPN(newValue);
    }

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
    return sessionModel
        .shouldShowGoogleAds((context, isGoogleAdsEnable, child) {
      return sessionModel.shouldShowCASAds((context, isCasAdsEnable, child) {
        adHelper.loadAds(
            shouldShowGoogleAds: isGoogleAdsEnable,
            shouldShowCASAds: isCasAdsEnable);
        return Transform.scale(
            scale: 2,
            child: vpnModel.vpnStatus(
                (BuildContext context, String vpnStatus, Widget? child) {
              return FlutterSwitch(
                  value:
                      vpnStatus == 'connected' || vpnStatus == 'disconnecting',
                  activeColor: onSwitchColor,
                  inactiveColor: offSwitchColor,
                  onToggle: (bool newValue) => onSwitchTap(newValue, vpnStatus,
                      (isGoogleAdsEnable || isCasAdsEnable)));
            }));
      });
    });
  }
}
