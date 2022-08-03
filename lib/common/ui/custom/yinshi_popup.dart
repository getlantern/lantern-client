import 'package:lantern/common/common.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showYinshiPopup(BuildContext context) async {
  CDialog(
    iconPath: ImagePaths.yinshi_logo,
    iconSize: 60,
    barrierDismissible: false,
    title: '${'announcing_yinshi'.i18n}',
    description: 'yinshi_description'.i18n,
    checkboxLabel: 'yinshi_dont_show_again'.i18n,
    dismissText: 'dismiss'.i18n.toUpperCase(),
    agreeText: 'visit_yinshi'.i18n.toUpperCase(),
    agreeTextColor: tsButtonPink,
    dismissAction: (doNotShowAgain) async {
      if (doNotShowAgain == true) await sessionModel.setSuppressYinshiPopup(doNotShowAgain);
    },
    maybeAgreeAction: (doNotShowAgain) async {
      const url =
          'https://yinshix.com'; //@todo should this go in a global constants or env?
      // if checkbox is checked, we suppress, if not, we dismiss
      if (doNotShowAgain == true) await sessionModel.setSuppressYinshiPopup(doNotShowAgain);
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        CDialog.showError(
          context,
          error: 'Could not launch $url in device browser.',
          stackTrace: null,
          description: 'browser_launch_error_description'.i18n,
        );
      }
      return true;
    },
  ).show(context);
}
