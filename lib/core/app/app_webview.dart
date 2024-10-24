import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

@RoutePage(name: 'AppWebview')
class AppWebView extends StatefulWidget {
  final String title;
  final String url;

  const AppWebView({
    super.key,
    required this.url,
    this.title = "",
  });

  @override
  State<AppWebView> createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  late InAppWebViewController webViewController;

  void showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        /*onLoadStop: (controller, url) async {
          _showWebViewUrl();
        },*/
        onReceivedHttpError: (controller, request, response) {
          print("HTTP error: ${response.statusCode} for ${request.url}");
          showErrorDialog("HTTP Error",
              "Status code: ${response.statusCode}\nDescription: ${response.reasonPhrase ?? ''}");
        },
        onReceivedError: (controller, request, error) =>
            showErrorDialog("Failed to load", error.description),
        initialSettings: InAppWebViewSettings(
          isInspectable: true,
          javaScriptEnabled: true,
          supportZoom: true,
          useWideViewPort: true,
          loadWithOverviewMode: true,
          builtInZoomControls: true,
          displayZoomControls: false,
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: true,
          underPageBackgroundColor: Colors.white,
          transparentBackground: true,
          // Windows-specific settings
          useHybridComposition: true,
        ),
        onProgressChanged: (controller, progress) {
          appLogger.i("Loading progress: $progress%");
        },
      ),
    );
  }

  Future<void> _showWebViewUrl() async {
    try {
      // Get the current URL from the WebView
      var currentUrl = await webViewController.getUrl();
      String urlToShow =
          currentUrl != null ? currentUrl.toString() : "No URL loaded";

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Current WebView URL"),
            content: Text(urlToShow),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to get URL: $e"),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

class AppBrowser extends InAppBrowser {
  final VoidCallback? onClose;

  static final InAppBrowserClassSettings settings = InAppBrowserClassSettings(
    browserSettings: InAppBrowserSettings(
      hideTitleBar: false,
      hideToolbarBottom: false,
      hideCloseButton: false,
      hideUrlBar: true,
      hidden: false,
      presentationStyle: ModalPresentationStyle.FULL_SCREEN,
    ),
    webViewSettings: InAppWebViewSettings(
      sharedCookiesEnabled: true,
      javaScriptEnabled: true,
      useOnDownloadStart: true,
      useShouldOverrideUrlLoading: true,
      isInspectable: kDebugMode,
    ),
  );

  AppBrowser({
    this.onClose,
  });

  static Future setProxyAddr() async {
    try {
      var proxyAvailable = await WebViewFeature.isFeatureSupported(
          WebViewFeature.PROXY_OVERRIDE);
      if (proxyAvailable) {
        ProxyController proxyController = ProxyController.instance();
        final proxyAddr = await sessionModel.proxyAddr();
        if (proxyAddr.isEmpty) {
          return;
        }
        await proxyController.clearProxyOverride();
        await proxyController.setProxyOverride(
            settings: ProxySettings(
          proxyRules: [ProxyRule(url: "http://$proxyAddr")],
          bypassRules: [],
        ));
        appLogger.e("Proxy set as :http://$proxyAddr");
      }
    } catch (e) {
      appLogger.e("Error setting proxy address: $e");
    }
  }

  @override
  Future onBrowserCreated() async {
    appLogger.i("Browser created");
  }

  @override
  Future onLoadStart(url) async {
    appLogger.i("Started displaying $url");
  }

  @override
  Future onLoadStop(url) async {
    appLogger.i("Stopped displaying $url");
  }

  @override
  void onReceivedError(WebResourceRequest request, WebResourceError error) =>
      appLogger.e("Can't load ${request.url}.. Error: ${error.description}",
          error: error);

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
      navigationAction) async {
    final url = navigationAction.request.url!;
    if (url.scheme.startsWith("alipay")) {
      launchUrl(
        url,
        mode: LaunchMode.platformDefault,
      );
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onProgressChanged(progress) {
    appLogger.i("Progress: $progress");
  }

  @override
  Future<void> onExit() async {
    appLogger.i("Browser closed");
    onClose?.call();
  }

  // navigateWebview navigates to the webview route and displays the given url
  static Future<void> navigateWebview(BuildContext context, String url) async {
    await context.pushRoute(
      AppWebview(
        url: url,
        title: 'lantern_pro_checkout'.i18n,
      ),
    );
  }

  // openWithSystemBrowser opens a URL in the browser
  static Future<void> openWithSystemBrowser(String url) async =>
      await InAppBrowser.openWithSystemBrowser(url: WebUri(url));

  static Future<void> openWebview(BuildContext context, String url) async {
    switch (Platform.operatingSystem) {
      case 'windows':
        await navigateWebview(context, url);
        break;
      case 'linux':
        await navigateWebview(context, url);
        break;
      case 'macos':
        await openWithSystemBrowser(url);
        break;
      case 'ios':
        await openWithSystemBrowser(url);
        break;
      default:
        await setProxyAddr();
        await _openUrlRequest(url);
        break;
    }
  }

  static Future<void> _openUrlRequest(String url) async {
    final instance = AppBrowser();
    await instance.openUrlRequest(
      urlRequest: URLRequest(url: WebUri(url), allowsCellularAccess: true),
      settings: settings,
    );
  }
}
