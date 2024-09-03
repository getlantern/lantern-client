import 'package:fixnum/fixnum.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/ui/app_webview.dart';

const defaultTimeoutDuration = Duration(seconds: 10);

bool isProdPlay() {
  const String? appFlavor = String.fromEnvironment('FLUTTER_APP_FLAVOR') != ''
      ? String.fromEnvironment('FLUTTER_APP_FLAVOR')
      : null;

  if (appFlavor != null) {
    return appFlavor == 'prodPlay';
  }
  return false;
}

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

enum Providers {
  shepherd,
  stripe,
  btcpay,
  freekassa,
  fropay,
  paymentwall,
  test
}

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
      case "shepherd":
        return Providers.shepherd;
      case "test":
        return Providers.test;
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
      if (provider == Providers.shepherd || provider == Providers.fropay) {
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

Plan planFromJson(Map<String, dynamic> item) {
  print("called plans $item");
  final locale = Localization.locale;
  final formatCurrency = NumberFormat.simpleCurrency(locale: locale);
  String currency = formatCurrency.currencyName != null
      ? formatCurrency.currencyName!.toLowerCase()
      : "usd";
  final res = jsonEncode(item);
  final plan = Plan.create()..mergeFromProto3Json(jsonDecode(res));
  if (plan.price[currency] == null) {
    final splitted = plan.id.split('-');
    if (splitted.length == 3) {
      currency = splitted[1];
    }
  }

  if (plan.price[currency] == null) {
    return plan;
  }
  if (plan.price[currency] != null) {
    final price = plan.price[currency] as Int64;
    plan.totalCost = formatCurrency.format(price.toInt() / 100.0).toString();
    plan.totalCostBilledOneTime =
        '${formatCurrency.format(price.toInt() / 100)} ${'billed_one_time'.i18n}';
  }
  return plan;
}

Map<String, PaymentMethod> paymentMethodsFromJson(List<dynamic> items) {
  final paymentMethods = Map<String, PaymentMethod>();
  items.forEach((value) {
    final json = jsonDecode(jsonEncode(value));
    final method = json['method'];
    final paymentMethod = PaymentMethod.create()
      ..mergeFromProto3Json({
        'method': method,
      });
    json['providers']?.forEach((e) {
      paymentMethod.providers.add(PaymentProviders.create()
        ..mergeFromProto3Json({
          "logoUrls": e['logoUrls'],
          "name": e['name'],
        }));
    });
    paymentMethods[method] = paymentMethod;
  });
  return paymentMethods;
}
