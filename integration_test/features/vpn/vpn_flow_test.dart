import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:lantern/core/widgtes/split_tunnel_widget.dart';
import 'package:lantern/features/vpn/vpn_bandwidth.dart';
import 'package:lantern/features/vpn/vpn_pro_banner.dart';
import 'package:lantern/features/vpn/vpn_server_location.dart';
import 'package:lantern/features/vpn/vpn_status.dart';
import 'package:lantern/features/vpn/vpn_switch.dart';
import 'package:lantern/features/vpn/vpn_tab.dart';
import '../../utils/test_utils.dart';

void main() {

  patrolTearDown(() async {
    await sl.reset();
  },);

  // tearDown(
  //   () async {
  //     await sl.reset();
  //   },
  // );

  patrolWidget(
    'renders VPN tap properly and navigation work properly',
        ($) async {
      await $(VPNTab).waitUntilVisible();
      await $.pump(const Duration(seconds: 6));

      expect($(ProBanner), findsOneWidget);
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

  patrolWidget(
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

  patrolNative(
    'VPN turn off/on on mobile platforms',
    skip: isDesktop(),
        ($) async {
      await createApp($);
      await $(VPNTab).waitUntilVisible();
      await $.pump(const Duration(seconds: 3));
      expect($('Disconnected'.i18n), findsOneWidget);
      await $(const AdvancedSwitch()).tap();
      await $.pump(const Duration(seconds: 1));
      //Turn on
      $.native.tap(Selector(text: 'OK'));
      await $.pumpAndSettle();
      expect($('connected'.i18n), findsOneWidget);
      expect($('Disconnected'.i18n), findsNothing);
      //Turn off
      await $.pump(const Duration(seconds: 1));
      await $(const AdvancedSwitch()).tap();
      expect($('connected'.i18n), findsNothing);
      expect($('Disconnected'.i18n), findsOneWidget);
    },
  );
}
