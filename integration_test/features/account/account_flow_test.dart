import 'package:lantern/features/account/follow_us.dart';
import 'package:lantern/features/checkout/feature_list.dart';
import 'package:lantern/features/checkout/plan_details.dart';

import '../../utils/test_utils.dart';

void main() {
  group(
    "account page end to end",
    () {
      patrolWidget(
        'render account screen and navigation test [free user]',
        ($) async {
          await $('Account'.i18n).tap();
          await $.pumpAndSettle();
          await $.pump(const Duration(seconds: 2));

          expect($(AppKeys.upgrade_lantern_pro).visible, equals(true));
          expect($(AppKeys.inviteFriends).visible, equals(true));
          expect($(AppKeys.devices).visible, equals(true));
          expect($(AppKeys.desktopVersion).visible, equals(true));
          expect($(AppKeys.followUs).visible, equals(true));
          expect($(AppKeys.support).visible, equals(true));
          expect($(AppKeys.setting).visible, equals(true));

          //check for navigation
          await $(AppKeys.upgrade_lantern_pro).tap();
          await $.pumpAndSettle();

          //plans page
          expect($(IconButton).visible, true);
          expect($(FullScreenDialog).visible, true);
          expect($(PlanCard), findsAtLeast(2));
          expect($(PlanCard).at(0).visible, true);
          expect($(PlanCard).at(1).visible, true);
          expect($(FeatureList), findsOneWidget);
          expect($('activation_lantern_pro_code'.i18n).visible, true);

          // go back
          await $(IconButton).tap();
          await $.pumpAndSettle();
          await $(AppKeys.inviteFriends).tap();
          await $.pumpAndSettle();

          //invite friends page
          expect($(ListItemFactory), findsOneWidget);
          expect($('share_lantern_pro'.i18n).visible, equals(true));
          expect($('share_referral_code'.i18n.toUpperCase()).visible, equals(true));
          expect($(Button).visible, equals(true));

          await $(IconButton).tap();

          // approve device page
          await $(AppKeys.devices).tap();
          await $.pumpAndSettle();
          expect($(Button), findsExactly(2));
          expect($('Link with PIN'.i18n.toUpperCase()).visible, true);
          expect($('Link via Email'.i18n.toUpperCase()).visible, true);

          await $(IconButton).tap();

          // desktop version
          await $(AppKeys.desktopVersion).tap();
          await $.pumpAndSettle();
          expect($(Button).visible, true);
          expect($(CAssetImage).visible, true);
          expect($('most_recent_lantern_apps'.i18n), findsOneWidget);
          expect($('most_recent_lantern_apps'.i18n).visible, true);
          expect($('share_link'.i18n.toUpperCase()).visible, true);

          await $(IconButton).tap();

          // follow us
          await $(AppKeys.followUs).tap();
          await $.pumpAndSettle();
          expect($(FollowUs).visible, true);
          await $.tester.tapAt(const Offset(10, 10));
          await $.pumpAndSettle();

          //support
          await $(AppKeys.support).tap();
          await $.pumpAndSettle();

          expect($(AppKeys.reportIssue).visible, true);
          expect($(AppKeys.userForum).visible, true);
          expect($(AppKeys.faq).visible, true);

          //report issue
          await $(AppKeys.reportIssue).tap();
          await $.pumpAndSettle();

          expect($(CTextField).at(0).visible, true);
          expect($(CTextField).at(1).visible, true);
          expect($(CTextField), findsExactly(2));
          expect($('email'.i18n), findsOneWidget);
          expect($('select_an_issue'.i18n), findsOneWidget);
          expect($(DropdownButtonFormField<String>), findsOneWidget);
          expect($(DropdownButtonFormField<String>).visible, true);
          expect($('send_report'.i18n.toUpperCase()).visible, true);
        },
      );
    },
  );
}
