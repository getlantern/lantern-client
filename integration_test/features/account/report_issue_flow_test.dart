import '../../utils/test_utils.dart';

void main() {
  appTearDown(
    () async {
      await sl.reset();
    },
  );

  patrol(
    "report issue end to end test",
    ($) async {
      await $('Account'.i18n).tap();
      await $.pumpAndSettle();
      await $(AppKeys.support).tap();
      await $.pumpAndSettle();
      await $(AppKeys.reportIssue).tap();
      await $.pumpAndSettle();

      expect($(CTextField), findsExactly(2));
      expect($(DropdownButtonFormField<String>), findsOneWidget);
      expect($('send_report'.i18n.toUpperCase()), findsOneWidget);
      expect($(Button), findsOneWidget);

      final email = $.tester.widget<CTextField>($(CTextField).at(0));
      final desc = $.tester.widget<CTextField>($(CTextField).at(1));
      final sendReport = $.tester.widget<Button>($(Button));

      email.controller.clear();
      desc.controller.clear();
      await $.pumpAndSettle();
      expect(sendReport.disabled, true);

      email.controller.text = 'test@gmail.com';
      await $(DropdownButtonFormField<String>).tap();
      await $('other'.i18n).tap();
      desc.controller.text = 'test description';
      await $.pumpAndSettle();
      await $.pump(const Duration(seconds: 2));

      expect(sendReport.onPressed, isNotNull);

    },
  );
}
