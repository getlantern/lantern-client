
import 'package:lantern/package_store.dart';

class VPNSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var vpnModel = context.watch<VpnModel>();
    return Transform.scale(
      scale: 2,
      child: vpnModel
          .vpnStatus((BuildContext context, String vpnStatus, Widget? child) {
        return FlutterSwitch(
          value: vpnStatus == 'connected' || vpnStatus == 'disconnecting',
          activeColor: HexColor(onSwitchColor),
          inactiveColor: HexColor(offSwitchColor),
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
