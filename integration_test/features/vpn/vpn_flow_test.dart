import 'package:lantern/core/utils/common.dart';
import 'package:lantern/core/widgtes/split_tunnel_widget.dart';
import 'package:lantern/features/vpn/vpn_bandwidth.dart';
import 'package:lantern/features/vpn/vpn_pro_banner.dart';
import 'package:lantern/features/vpn/vpn_server_location.dart';
import 'package:lantern/features/vpn/vpn_status.dart';
import 'package:lantern/features/vpn/vpn_switch.dart';
import 'package:lantern/features/vpn/vpn_tab.dart';
import 'package:lantern/main.dart' as app;
import '../../utils/test_utils.dart';

void main() {
  setUp(
    () {},
  );

  tearDown(
    () {
      sl.reset();
    },
  );

  group(
    'vpn tap end to end test',
    () {
      patrolWidgetTest(
        'renders VPN tap properly',
        ($) async {
          await app.main();
          await $.pumpAndSettle();
          await $(VPNTab).waitUntilVisible();
          await $.pump(const Duration(seconds: 6));

          expect($(ProBanner), findsOneWidget);
          expect($(VPNSwitch), findsOneWidget);
          expect($(VPNStatus), findsOneWidget);
          expect($(ServerLocationWidget), findsOneWidget);
          expect($(VPNBandwidth), findsOneWidget);
          if (isAndroid()) {
            expect($(SplitTunnelingWidget), findsOneWidget);
          }else{
            expect($(SplitTunnelingWidget), findsNothing);
          }

        },
      );

      patrolWidgetTest(
        'renders VPN tap navigation work properly',
        ($) async {
          await app.main();
          await $.pumpAndSettle();
          await $(VPNTab).waitUntilVisible();
          await $.pump(const Duration(seconds: 6));
          await $(ProBanner).tap();
          await $.pumpAndSettle();
          await $.pump(const Duration(seconds: 1));
          expect($(FullScreenDialog), findsOneWidget);
          if (isAndroid()) {
            //go back
            await $(IconButton).tap();
            await $.pumpAndSettle();
            await $('split_tunneling'.i18n).tap();
            await $.pumpAndSettle();
            expect($('split_tunneling'.i18n), findsOneWidget);
          }
        },
      );
    },
  );
}
