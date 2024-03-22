import 'package:lantern/account/split_tunneling.dart';
import 'package:lantern/common/common_desktop.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:lantern/vpn/vpn.dart';
import 'vpn_bandwidth.dart';
import 'vpn_pro_banner.dart';
import 'vpn_server_location.dart';
import 'vpn_status.dart';
import 'vpn_switch.dart';

class VPNTab extends StatefulWidget {
  const VPNTab({Key? key}) : super(key: key);

  @override
  _VPNTabState createState() => _VPNTabState();
}

class _VPNTabState extends State<VPNTab> {
  WebsocketImpl websocket = WebsocketImpl();

  @override
  void initState() {
    if (isDesktop()) {
      connectDesktopSocket();
    }
    super.initState();
  }

  void connectDesktopSocket() {
    try {
      websocket.connect(Uri.parse('ws://${websocketAddr()}/data'));
      appLogger.i("Socket connected");
    } catch (e) {
      appLogger.e('Error connecting to socket: $e');
    }
  }

  @override
  void dispose() {
    websocket.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return sessionModel.proUser(
        (BuildContext context, bool proUser, Widget? child) {
      return BaseScreen(
        title: SvgPicture.asset(
          proUser ? ImagePaths.pro_logo : ImagePaths.free_logo,
          height: 16,
          fit: BoxFit.contain,
        ),
        // make sure to disable the back arrow button on the home screen
        automaticallyImplyLeading: false,
        padVertical: true,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!proUser && !Platform.isIOS) ProBanner() else const SizedBox(),
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
                  if (Platform.isAndroid) ...{
                    const CDivider(height: 32.0),
                    SplitTunnelingWidget(),
                    if (!proUser) const VPNBandwidth(),
                  }
                ],
              ),
            ),
          ],
        ),
      );
    }, websocket);
  }
}
