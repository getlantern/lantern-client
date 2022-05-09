import 'package:lantern/messaging/messaging.dart';
import 'package:lantern/vpn/vpn.dart';

import 'vpn_bandwidth.dart';
import 'vpn_pro_banner.dart';
import 'vpn_server_location.dart';
import 'vpn_status.dart';
import 'vpn_switch.dart';

class VPNTab extends StatelessWidget {
  final bool platinumAvailable;
  final bool isPlatinum;

  VPNTab({Key? key, required this.platinumAvailable, required this.isPlatinum})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return sessionModel.getCachedUserLevel(
        (BuildContext context, String userLevel, Widget? child) {
      return BaseScreen(
        title: SvgPicture.asset(
          isPlatinum
              ? ImagePaths.lantern_platinum_logotype
              : userLevel == 'pro'
                  ? ImagePaths.pro_logo
                  : ImagePaths.free_logo,
          height: 16,
          fit: BoxFit.contain,
        ),
        padVertical: true,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            (platinumAvailable && isPlatinum) ||
                    (!platinumAvailable && (userLevel == 'pro'))
                ? Container()
                : ProBanner(
                    platinumAvailable: platinumAvailable,
                    isPlatinum: isPlatinum,
                  ),
            VPNSwitch(),
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
                children: [
                  VPNStatus(),
                  Container(
                    child: const CDivider(height: 32.0),
                  ),
                  ServerLocationWidget(),
                  VPNBandwidth(),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
