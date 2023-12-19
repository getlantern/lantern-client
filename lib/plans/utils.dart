import 'package:lantern/common/common.dart';

const defaultTimeoutDuration = Duration(seconds: 10);

const lanternStarLogo = CAssetImage(
  path: ImagePaths.lantern_star,
  size: 72,
);

void onAPIcallTimeout({code, message}) {
  throw PlatformException(
    code: code,
    message: message,
  );
}

void showSuccessDialog(
  BuildContext context,
  bool isPro, {
  bool? isReseller,
  VoidCallback? onAgree,
  bool barrierDismissible = true,
}) {
  String description, title;
  if (isReseller != null && isReseller) {
    title = 'renewal_success'.i18n;
    description = 'reseller_success'.i18n;
  } else if (isPro) {
    title = 'renewal_success'.i18n;
    description = 'pro_renewal_success_description'.i18n;
  } else {
    title = 'pro_purchase_success'.i18n;
    description = 'pro_purchase_success_descripion'.i18n;
  }
  CDialog.showInfo(
    context,
    icon: lanternStarLogo,
    title: title,
    description: description,
    actionLabel: 'continue_to_pro'.i18n,
    barrierDismissible: barrierDismissible,
    agreeAction: () async {
      if (onAgree != null) {
        onAgree();
        return true;
      }
      // Note: whatever page you need to popUtil
      // it will pop that page
      context.router.popUntil((route) => route.settings.name == PlansPage.name);
      return true;
    },
  );
}
