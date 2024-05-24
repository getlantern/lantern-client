import 'package:lantern/vpn/vpn.dart';

class ServerLocationWidget extends StatelessWidget {
  const ServerLocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CInkWell(
      onTap: () => CDialog.showInfo(
        context,
        title: 'Server Location'.i18n,
        description: 'Server Location Info'.i18n,
        iconPath: ImagePaths.location_on,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CText(
            'Server Location'.i18n,
            textAlign: TextAlign.center,
            style: tsSubtitle3.copiedWith(
              color: unselectedTabIconColor,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 8,
            ),
            transform: Matrix4.translationValues(0.0, 2.0, 0.0),
            child: Icon(
              Icons.info_outline_rounded,
              color: unselectedTabIconColor,
              size: 16,
            ),
          ),
          const Spacer(),
          vpnModel.vpnStatus(
              (BuildContext context, String vpnStatus, Widget? child) {
            return sessionModel.serverInfo(
                (BuildContext context, ServerInfo serverInfo, Widget? child) {
              if (vpnStatus == 'connected' || vpnStatus == 'disconnecting') {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      child: Flag.fromString(
                        serverInfo.countryCode,
                        height: 24,
                        width: 36,
                      ),
                    ),
                    const SizedBox(width: 12),
                    CText(
                      serverInfo.city,
                      style: tsSubtitle4,
                      textAlign: TextAlign.center,
                    )
                  ],
                );
              } else {
                return CText(
                  'n/a'.i18n.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: tsSubtitle4,
                );
              }
            });
          }),
        ],
      ),
    );
  }
}