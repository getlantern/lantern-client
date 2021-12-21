import 'package:lantern/vpn/vpn.dart';

class ServerLocationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CText(
          'Server Location'.i18n,
          style: tsBody1.copiedWith(
            color: unselectedTabIconColor,
          ),
        ),
        Container(
          transform: Matrix4.translationValues(0.0, 2.0, 0.0),
          child: CInkWell(
            onTap: () => showInfoDialog(
              context,
              title: 'Server Location'.i18n,
              des: 'Server Location Info'.i18n,
              assetPath: ImagePaths.location_on,
              confirmButtonText: 'OK'.i18n,
              confirmButtonAction: () async => await context.router.pop(),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: unselectedTabIconColor,
              size: 16,
            ),
          ),
        ),
        const Spacer(),
        vpnModel
            .vpnStatus((BuildContext context, String vpnStatus, Widget? child) {
          return vpnModel.serverInfo(
              (BuildContext context, ServerInfo serverInfo, Widget? child) {
            if (vpnStatus == 'connected' || vpnStatus == 'disconnecting') {
              return Row(
                children: [
                  ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      child:
                          Flag(serverInfo.countryCode, height: 24, width: 36),),
                  const SizedBox(width: 12),
                  CText(
                    serverInfo.city,
                    style: tsSubtitle2,
                  )
                ],
              );
            } else {
              return CText(
                'n/a'.i18n.toUpperCase(),
                style: tsSubtitle2,
              );
            }
          });
        }),
      ],
    );
  }
}
