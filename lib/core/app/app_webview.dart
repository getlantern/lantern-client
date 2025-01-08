import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/core/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool isLoading = true;

  void showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('continue'.i18n),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future setProxyAddr() async {
    try {
      var proxyAvailable = await WebViewFeature.isFeatureSupported(
          WebViewFeature.PROXY_OVERRIDE);
      if (proxyAvailable) {
        final proxyAddr = await sessionModel.proxyAddr();
        if (proxyAddr.isNotEmpty) {
          ProxyController.instance()
            ..clearProxyOverride()
            ..setProxyOverride(
                settings: ProxySettings(
              proxyRules: [ProxyRule(url: "http://$proxyAddr")],
              bypassRules: [],
            ));
          appLogger.i("Proxy set as: http://$proxyAddr");
        }
      }
    } catch (e) {
      appLogger.e("Error setting proxy address: $e");
    }
  }

  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
      InAppWebViewController controller,
      NavigationAction navigationAction) async {
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
  Widget build(BuildContext context) {
    return BaseScreen(
      title: widget.title,
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            onWebViewCreated: (controller) {
              webViewController = controller;
              setProxyAddr();
            },
            webViewEnvironment: webViewEnvironment,
            onLoadStart: (controller, url) => setState(() => isLoading = true),
            onLoadStop: (controller, url) => setState(() => isLoading = false),
            onReceivedHttpError: (controller, request, response) {
              appLogger
                  .i("HTTP error: ${response.statusCode} for ${request.url}");
              if (!isAppiumTest()) {
                showErrorDialog("HTTP Error",
                    "Status code: ${response.statusCode}\nDescription: ${response.reasonPhrase ?? ''}");
              }
            },
            shouldOverrideUrlLoading:
                isAppiumTest() ? null : shouldOverrideUrlLoading,
            onReceivedError: (controller, request, error) {
              if (!isAppiumTest()) {
                showErrorDialog("Failed to load", error.description);
              }
            },
            initialSettings: InAppWebViewSettings(
                isInspectable: kDebugMode,
                javaScriptEnabled: true,
                supportZoom: true,
                domStorageEnabled: true,
                allowFileAccess: true,
                useWideViewPort: false,
                loadWithOverviewMode: true,
                clearCache: true,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                builtInZoomControls: Platform.isAndroid,
                displayZoomControls: false,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: false,
                underPageBackgroundColor: Colors.white,
                transparentBackground: true,
                allowFileAccessFromFileURLs: true,
                //We want to use mobile mode for webview on desktop
                //  Since we are showign app on mobile size it will be better to use mobile mode
                // showing recommended mode user has to scroll a lot
                preferredContentMode: UserPreferredContentMode.MOBILE),
            onProgressChanged: (controller, progress) =>
                appLogger.i("Loading progress: $progress%"),
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

WebViewEnvironment? webViewEnvironment;

Future<void> initializeWebViewEnvironment() async {
  if (Platform.isWindows) {
    final directory = await getApplicationSupportDirectory();
    final localAppDataPath = directory.path;

    // Ensure WebView2 runtime is available
    final availableVersion = await WebViewEnvironment.getAvailableVersion();
    assert(availableVersion != null,
        'Failed to find WebView2 Runtime or non-stable Microsoft Edge installation.');

    webViewEnvironment = await WebViewEnvironment.create(
      settings: WebViewEnvironmentSettings(
        userDataFolder: '$localAppDataPath\\Lantern\\WebView2',
      ),
    );
  }
}

// openWithSystemBrowser opens a URL in the browser
Future<void> openWithSystemBrowser(String url) async {
  switch (Platform.operatingSystem) {
    case 'linux':
      final webview = await WebviewWindow.create();
      webview.launch(url);
      break;
    default:
      await InAppBrowser.openWithSystemBrowser(url: WebUri(url));
  }
}

Future<void> openWebview(BuildContext context, String url,
    [String? title]) async {
  try {
    switch (Platform.operatingSystem) {
      case 'android':
      case 'macos':
      case 'windows':
        await context.pushRoute(AppWebview(url: url, title: title ?? ''));
        break;
      case 'linux':
        final webview = await WebviewWindow.create();
        webview.launch(url);
        break;
      case 'ios':
        await openWithSystemBrowser(url);
        break;
      default:
        throw UnsupportedError('Platform not supported');
    }
  } catch (e) {
    appLogger.e("Failed to open webview", error: e);
  }
}
