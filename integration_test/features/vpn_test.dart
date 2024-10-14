import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lantern/features/vpn/vpn_switch.dart';
import 'package:lantern/main.dart' as app;
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    "VPN test end to end",
    (petrolTester) async {
      await app.main();

      await petrolTester.pumpAndSettle();




      expect(petrolTester(VPNSwitch()), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
    config: PatrolTesterConfig(

    ),
  );
}
