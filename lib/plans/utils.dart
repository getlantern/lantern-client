import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/ui/app_webview.dart';

const defaultTimeoutDuration = Duration(seconds: 10);

const lanternStarLogo = CAssetImage(
  path: ImagePaths.lantern_star,
  size: 72,
);

final featuresList = [
  'unlimited_data'.i18n,
  'faster_data_centers'.i18n,
  'no_logs'.i18n,
  'connect_up_to_3_devices'.i18n,
  'no_ads'.i18n,
];

void onAPIcallTimeout({code, message}) {
  throw PlatformException(
    code: code,
    message: message,
  );
}

void showError(
  BuildContext context, {
  Object? error,
  StackTrace? stackTrace,
  String description = '',
}) {
  if (description.isEmpty) {
    if (error is PlatformException) {
      description = (error).message.toString().i18n;
    } else {
      description = error.toString();
    }
  }
  CDialog.showError(
    context,
    error: error,
    stackTrace: stackTrace,
    description: description,
  );
}

void showSuccessDialog(BuildContext context, bool isPro, [bool? isReseller]) {
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
    agreeAction: () async {
      // Note: whatever page you need to popUtil
      // it will pop that page
      context.router.popUntil((route) => route.settings.name == PlansPage.name);
      return true;
    },
  );
}

enum Providers { stripe, btcpay, freekassa, fropay, paymentwall }

extension ProviderExtension on String {
  Providers toPaymentEnum() {
    switch (this) {
      case "btcpay":
        return Providers.btcpay;
      case "freekassa":
        return Providers.freekassa;
      case "fropay":
        return Providers.fropay;
      case "paymentwall":
        return Providers.paymentwall;
      default:
        return Providers.stripe;
    }
  }
}

extension PlansExtension on Plan {
  double monthlyCost(double totalPrice) {
    if (id.startsWith('1y')) {
      return totalPrice / 12;
    }

    return totalPrice / 24;
  }
}

Future<void> openDesktopWebview(
    {required BuildContext context,
    required String redirectUrl,
    required Providers provider,
    VoidCallback? onClose}) async {
  switch (Platform.operatingSystem) {
    case 'windows':
      await AppBrowser.openWindowsWebview(redirectUrl);
      break;
    case 'macos':
      if (provider == Providers.fropay) {
        // Open with system browser browser on mac due to not able to by pass human verification.
        await InAppBrowser.openWithSystemBrowser(url: WebUri(redirectUrl));
      } else {
        final browser = AppBrowser(onClose: onClose);
        await browser.openMacWebview(redirectUrl);
      }
      break;
    default:
      await context.pushRoute(
          AppWebview(title: 'lantern_pro_checkout'.i18n, url: redirectUrl));
  }
}
