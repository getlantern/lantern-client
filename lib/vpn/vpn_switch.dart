import 'package:lantern/vpn/vpn.dart';

class VPNSwitch extends StatelessWidget {
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
          onToggle: (bool newValue) async {
            await HapticFeedback.lightImpact();
            if (vpnStatus != 'connecting' || vpnStatus != 'disconnecting') {
              await vpnModel.switchVPN(newValue);
            }
          },
        );
      }),
    );
  }
}
