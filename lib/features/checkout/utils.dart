import 'package:lantern/core/utils/common.dart';

// Make sure payment URLs for certain providers (like Alipay) are HTTPS
String securePaymentRedirectUrl(String url) {
  if (url.startsWith("http://") && url.contains("alipay")) {
    return url.replaceFirst("http://", "https://");
  }
  return url;
}

/// Opens a payment webview
/// - Rewrites http://alipay URLs to https and opens in-app
/// - Opens http URLs in system browser
/// - Open all others in-app
Future<void> openPaymentWebview(BuildContext context, String url,
    {String? title}) async {
  if (url.startsWith('http://')) {
    if (url.contains("alipay")) {
      url = securePaymentRedirectUrl(url);
    } else {
      await openWithSystemBrowser(url);
      return;
    }
  }
  await openWebview(context, url, title);
}
