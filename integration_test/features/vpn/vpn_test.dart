import 'package:flutter/cupertino.dart';
import 'package:lantern/features/vpn/vpn_switch.dart';
import '../../utils/test_utils.dart';
import  'package:lantern/main.dart' as app;

void main() {
  patrolTest(
    "VPN test end to end",
    (petrolTester) async {
      await petrolTester.pumpAndSettle();
      expect(petrolTester(const VPNSwitch()), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
    config: const PatrolTesterConfig(),
  );
}
