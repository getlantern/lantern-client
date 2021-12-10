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
          onToggle: (bool newValue) {
            if (vpnStatus != 'connecting' || vpnStatus != 'disconnecting') {
              vpnModel.switchVPN(newValue);
            }
          },
        );
      }),
    );
  }
}
