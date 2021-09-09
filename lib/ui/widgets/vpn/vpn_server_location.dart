import 'dart:ui';

import 'package:lantern/package_store.dart';

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
        Text(
          'Server Location'.i18n + ': ',
          style: tsTitleHeadVPNItem.copyWith(
            color: unselectedTabLabelColor,
          ),
        ),
        Container(
          transform: Matrix4.translationValues(-16.0, 0.0, 0.0),
          child: InkWell(
            onTap: _onTap,
            child: Container(
              height: 48,
              width: 48,
              child: Icon(
                Icons.info_outline_rounded,
                color: unselectedTabLabelColor,
                size: 16,
              ),
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
                  Text(
                    serverInfo.city,
                    style: tsTitleTrailVPNItem,
                  )
                ],
              );
            } else {
              return Text(
                'n/a'.i18n,
                style: tsTitleTrailVPNItem,
              );
            }
          });
        }),
      ],
    );
  }
}
