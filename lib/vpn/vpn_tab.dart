import 'package:lantern/messaging/messaging.dart';
import 'package:lantern/vpn/vpn.dart';

import 'try_lantern_chat.dart';
import 'vpn_bandwidth.dart';
import 'vpn_pro_banner.dart';
import 'vpn_server_location.dart';
import 'vpn_status.dart';
import 'vpn_switch.dart';

class VPNTab extends StatelessWidget {
  VPNTab({Key? key}) : super(key: key);

  void _openInfoServerLocation(BuildContext context) {
    showInfoDialog(context,
        title: 'Server Location'.i18n,
        des: 'Server Location Info'.i18n,
        assetPath: ImagePaths.location_on,
        buttonText: 'OK'.i18n);
  }

  @override
  Widget build(BuildContext context) {
    return sessionModel
        .proUser((BuildContext context, bool proUser, Widget? child) {
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
            proUser ? Container() : ProBanner(),
            // TODO: take out
            Button(
                text: 'show modal',
                onPressed: () async {
                  await context.router
                      .push(FullScreenDialogPage(widget: TryLanternChat()));
                }),
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
                  ServerLocationWidget(_openInfoServerLocation),
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
