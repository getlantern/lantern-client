import 'package:lantern/vpn/vpn.dart';
import '../ad_helper.dart';

class VPNSwitch extends StatefulWidget {
  @override
  State<VPNSwitch> createState() => _VPNSwitchState();
}

class _VPNSwitchState extends State<VPNSwitch> {
  final adHelper = AdHelper();

  @override
  void initState() {
    super.initState();
    adHelper.loadInterstitialAd();
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
          await adHelper.showAd();
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
            onToggle: (bool newValue) => onSwitchTap(newValue, vpnStatus),
          );
        }));
  }
}
