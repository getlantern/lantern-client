import 'package:lantern/model/session_model.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/hex_color.dart';
import 'package:provider/provider.dart';

import 'vpn_bandwidth.dart';
import 'vpn_custom_divider.dart';
import 'vpn_pro_banner.dart';
import 'vpn_server_location.dart';
import 'vpn_status.dart';
import 'vpn_switch.dart';

class VPNTab extends StatelessWidget {
  VPNTab({Key? key}) : super(key: key);

  void _openInfoServerLocation(BuildContext context) {
    showInfoDialog(
      context,
      title: 'Server Location'.i18n,
      des: 'Server Location Info'.i18n,
      icon: ImagePaths.location_on_icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();

    return sessionModel
        .proUser((BuildContext context, bool proUser, Widget? child) {
      return BaseScreen(
        logoTitle: proUser ? ImagePaths.pro_logo : ImagePaths.free_logo,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              proUser ? Container() : ProBanner(),
              VPNSwitch(),
              Container(
                padding: const EdgeInsetsDirectional.only(
                    start: 16, end: 20, top: 20, bottom: 0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: HexColor(borderColor),
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(borderRadius),
                  ),
                ),
                child: Column(
                  children: [
                    VPNStatus(),
                    const VPNCustomDivider(marginBottom: 0),
                    ServerLocationWidget(_openInfoServerLocation),
                    VPNBandwidth(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
