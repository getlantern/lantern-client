import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lantern/core/utils/common.dart';
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
  final InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    javaScriptEnabled: true,
    supportZoom: true,
    useWideViewPort: true,
    loadWithOverviewMode: true,
    builtInZoomControls: true,
    displayZoomControls: false,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: false,
    underPageBackgroundColor: Colors.white,
    allowBackgroundAudioPlaying: false,
    allowFileAccessFromFileURLs: true,
    preferredContentMode: UserPreferredContentMode.MOBILE,
  );

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: widget.title,
      showAppBar: true,
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        initialSettings: InAppWebViewSettings(
          isInspectable: kDebugMode,
          javaScriptEnabled: true,
          supportZoom: true,
          useWideViewPort: true,
          loadWithOverviewMode: true,
          builtInZoomControls: true,
          displayZoomControls: false,
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: false,
          underPageBackgroundColor: Colors.white,
          allowBackgroundAudioPlaying: false,
          allowFileAccessFromFileURLs: true,
          preferredContentMode: UserPreferredContentMode.MOBILE,
        ),
        onProgressChanged: (controller, progress) {
          appLogger.i("Loading progress: $progress%");
        },
      ),
    );
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
    var proxyAvailable =
        await WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE);
    if (proxyAvailable) {
      ProxyController proxyController = ProxyController.instance();
      final proxyAddr = await sessionModel.proxyAddr();
      await proxyController.clearProxyOverride();
      await proxyController.setProxyOverride(
          settings: ProxySettings(
        proxyRules: [ProxyRule(url: "http://$proxyAddr")],
        bypassRules: [],
      ));
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
  static Future<void> navigateWebview(BuildContext context, String url) async =>
      await context.pushRoute(
        AppWebview(
          url: url,
          title: 'lantern_pro_checkout'.i18n,
        ),
      );

  // openWithSystemBrowser opens a URL in the browser
  static Future<void> openWithSystemBrowser(String url) async =>
      await InAppBrowser.openWithSystemBrowser(url: WebUri(url));

  static Future<void> openWebview(BuildContext context, String url) async {
    switch (Platform.operatingSystem) {
      case 'windows':
        await navigateWebview(context, url);
        break;
      case 'macos':
        await openWithSystemBrowser(url);
      case 'ios':
        await openWithSystemBrowser(url);
        break;
      default:
        await setProxyAddr();
        final instance = AppBrowser();
        await instance.openUrlRequest(
          urlRequest: URLRequest(url: WebUri(url), allowsCellularAccess: true),
          settings: settings,
        );
        break;
    }
  }
}
