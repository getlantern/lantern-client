import 'package:lantern/vpn/vpn.dart';

class ServerLocationWidget extends StatefulWidget {
  final ValueChanged<BuildContext> openInfoServerLocation;

  ServerLocationWidget(this.openInfoServerLocation) : super();

  @override
  _ServerLocationWidgetState createState() => _ServerLocationWidgetState();
}

class _ServerLocationWidgetState extends State<ServerLocationWidget> {
  void _onTap() {
    widget.openInfoServerLocation(context);
  }

  @override
  Widget build(BuildContext context) {
    var vpnModel = context.watch<VpnModel>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CText(
          'Server Location'.i18n + ': ',
          style: tsBody.copiedWith(
            color: unselectedTabLabelColor,
          ),
        ),
        Container(
          transform: Matrix4.translationValues(0.0, 2.0, 0.0),
          child: InkWell(
            onTap: _onTap,
            child: Icon(
              Icons.info_outline_rounded,
              color: unselectedTabLabelColor,
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
                          Flag(serverInfo.countryCode, height: 24, width: 36)),
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
