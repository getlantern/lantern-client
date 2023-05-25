import 'package:lantern/vpn/vpn.dart';

class VPNStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return vpnModel
        .vpnStatus((BuildContext context, String vpnStatus, Widget? child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CText(
            'VPN Status'.i18n,
            style: tsSubtitle3.copiedWith(
              color: unselectedTabIconColor,
            ),
          ),
          (vpnStatus == 'connecting' || vpnStatus == 'disconnecting')
              ? Row(
                  children: [
                    CText(
                      (vpnStatus == 'connecting')
                          ? 'Connecting'.i18n
                          : 'Disconnecting'.i18n,
                      style: tsSubtitle4,
                    ),
                    const Padding(
                      padding: EdgeInsetsDirectional.only(start: 12),
                      child: SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  ],
                )
              : CText(
                  (vpnStatus == 'connected')
                      ? 'connected'.i18n
                      : 'Disconnected'.i18n,
                  style: tsSubtitle4,
                ),
        ],
      );
    });
  }
}
