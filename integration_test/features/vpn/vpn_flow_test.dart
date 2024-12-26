import 'package:animated_toggle_switch/animated_toggle_switch.dart';
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
  appTearDown(
    () async {
      await sl.reset();
    },
  );

  patrol(
    'renders VPN tap properly and navigation work properly',
    ($) async {
      await $(VPNTab).waitUntilVisible();
      await $.pump(const Duration(seconds: 6));

      if (sessionModel.proUserNotifier.value ?? false) {
        expect($(ProBanner), findsNothing);
      } else {
        expect($(ProBanner), findsOneWidget);
      }

      if (isMobile()) {
        expect($(VPNSwitch), findsOneWidget);
      } else {
        expect($(CustomAnimatedToggleSwitch<String>), findsOneWidget);
      }
      expect($(VPNStatus), findsOneWidget);
      expect($(ServerLocationWidget), findsOneWidget);
      expect($(VPNBandwidth), findsOneWidget);
      if (isAndroid()) {
        expect($(SplitTunnelingWidget), findsOneWidget);
      } else {
        expect($(SplitTunnelingWidget), findsNothing);
      }

      await $(ProBanner).tap();
      await $.pumpAndSettle();
      await $.pump(const Duration(seconds: 1));
      expect($(FullScreenDialog), findsOneWidget);
      await $(IconButton).tap();
      expect($(FullScreenDialog), findsNothing);
      await $.pumpAndSettle();
      if (isAndroid()) {
        await $.pump(const Duration(seconds: 1));
        await $('split_tunneling'.i18n).tap();
        await $.pump(const Duration(seconds: 1));
        expect($('split_tunneling'.i18n), findsOneWidget);
        await $(IconButton).tap();
        await $.pumpAndSettle();
      }
    },
  );

  patrol(
    'toggles VPN switch on & off for desktop platforms',
    skip: isMobile(),
    ($) async {
      await $.pump(const Duration(seconds: 3));
      await $(CustomAnimatedToggleSwitch<String>).tap();
      await $.pumpAndSettle();
      await $.pump(const Duration(seconds: 1));
      expect($('connected'.i18n), findsOneWidget);
      await $.pump(const Duration(seconds: 2));

      await $(CustomAnimatedToggleSwitch<String>)
          .tap(settlePolicy: SettlePolicy.settle);
      await $.pumpAndSettle();
      await $.pump(const Duration(seconds: 1));
      expect($('connected'.i18n), findsNothing);
      expect($('Disconnected'.i18n), findsOneWidget);
    },
  );

  if (isMobile()) {
    patrolTest(
      "VPN end to end",
      skip: isDesktop(),
      ($) async {
        await app.main(testMode: true);
        await $.pumpAndSettle();
        await $(VPNTab).waitUntilVisible();
        await $.pump(const Duration(seconds: 6));
        expect($('Disconnected'.i18n), findsOneWidget);
        await $(AdvancedSwitch).tap();
        await $.pump(const Duration(seconds: 1));

        try {
          //Turn on
          await $.native.tap(Selector(text: 'OK'));
        } on PatrolActionException {
          //Do nothing it means user has already accepted the dialog
        }
        await $.pumpAndSettle();
        await $.pump(const Duration(seconds: 1));
        expect($('connected'.i18n), findsOneWidget);
        expect($('Disconnected'.i18n), findsNothing);

        //Tun off
        await $(AdvancedSwitch).tap();
        await $.pumpAndSettle();
        await $.pump(const Duration(seconds: 1));
        expect($('connected'.i18n), findsNothing);
        expect($('Disconnected'.i18n), findsOneWidget);
      },
    );
  }
}
