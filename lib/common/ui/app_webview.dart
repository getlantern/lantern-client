import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_windows_webview/flutter_windows_webview.dart';
import 'package:lantern/common/common.dart';
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
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        initialSettings: settings,
        onProgressChanged: (controller, progress) {
          appLogger.i("Progress: $progress");
        },
      ),
    );
  }
}

class AppBrowser extends InAppBrowser {
  final VoidCallback? onClose;

  static final InAppBrowserClassSettings settings = InAppBrowserClassSettings(
    browserSettings: InAppBrowserSettings(
      hideTitleBar: true,
      hideToolbarBottom: true,
      presentationStyle: ModalPresentationStyle.POPOVER,
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
    print("Browser created");
  }

  @override
  Future onLoadStart(url) async {
    print("Started displaying $url");
  }

  @override
  Future onLoadStop(url) async {
    print("Stopped displaying $url");
  }

  @override
  void onReceivedError(WebResourceRequest request, WebResourceError error) {
    print("Can't load ${request.url}.. Error: ${error.description}");
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
      navigationAction) async {
    final url = navigationAction.request.url!;
    if (url.scheme.startsWith("alipay") && await canLaunchUrl(url)) {
      launchUrl(url, mode: LaunchMode.platformDefault);
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onProgressChanged(progress) {
    print("Progress: $progress");
  }

  @override
  Future<void> onExit() async {
    print("Browser closed");
    onClose?.call();
  }

  Future<void> openMacWebview(String url) async {
    await openUrlRequest(
            urlRequest: URLRequest(url: WebUri(url)), settings: settings)
        .then(
      (value) {
        print("open mac webview");
      },
    );
  }

  static Future<void> openWindowsWebview(String url) async {
    FlutterWindowsWebview().launchWebview(url);
  }

  static Future<void> openWebview(String url) async {
    switch (Platform.operatingSystem) {
      case 'windows':
        await openWindowsWebview(url);
        break;
      case 'macos':

        ///**Officially Supported Platforms/Implementations**:
        ///- Android native WebView
        ///- iOS
        ///- MacOS
        InAppBrowser.openWithSystemBrowser(url: WebUri(url));
        break;
      default:
        await setProxyAddr();
        final instance = AppBrowser();
        await instance.openUrlRequest(
          urlRequest: URLRequest(url: WebUri(url)),
          settings: settings,
        );
        break;
    }
  }
}
