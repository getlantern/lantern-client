import 'package:lantern/account/split_tunneling.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:lantern/vpn/vpn.dart';

import 'vpn_bandwidth.dart';
import 'vpn_pro_banner.dart';
import 'vpn_server_location.dart';
import 'vpn_status.dart';
import 'vpn_switch.dart';

class VPNTab extends StatelessWidget {
  const VPNTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const proUser = false;
    return BaseScreen(
        title: SvgPicture.asset(
          proUser ? ImagePaths.pro_logo : ImagePaths.free_logo,
          height: 16,
          fit: BoxFit.contain,
        ),
        padVertical: true,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if(!proUser && !Platform.isIOS)
            ProBanner()
            else
              const SizedBox(),
            const VPNSwitch(),
            Container(
              padding: const EdgeInsetsDirectional.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: borderColor,
                  width: 1,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(borderRadius),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VPNStatus(),
                  const CDivider(height: 32.0),
                  ServerLocationWidget(),
                  if(Platform.isAndroid)...{
                    const CDivider(height: 32.0),
                    SplitTunnelingWidget(),
                    if(!proUser)
                     const VPNBandwidth(),
                  }
                  ],
              ),
            ),
          ],
        ),
      );
  }
}
