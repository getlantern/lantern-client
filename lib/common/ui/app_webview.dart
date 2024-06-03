import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_windows_webview/flutter_windows_webview.dart';
import 'package:lantern/common/common.dart';

@RoutePage(name: 'AppWebview')
class AppWebView extends StatefulWidget {
  final String title;
  final String url;

  const AppWebView({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<AppWebView> createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  final InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: false,
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
  final InAppBrowserClassSettings settings = InAppBrowserClassSettings(
      browserSettings: InAppBrowserSettings(hideUrlBar: true),
      webViewSettings: InAppWebViewSettings(
          javaScriptEnabled: true, isInspectable: kDebugMode));

  AppBrowser({
    required this.onClose,
  });

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
    onClose?.call();
  }

  @override
  void onReceivedError(WebResourceRequest request, WebResourceError error) {
    appLogger.i("Can't load ${request.url}.. Error: ${error.description}");
  }

  @override
  void onProgressChanged(progress) {
    appLogger.i("Progress: $progress");
  }

  @override
  void onExit() {
    appLogger.i("Browser closed");
  }

  Future<void> openMacWebview(String url) async {
    await openUrlRequest(
        urlRequest: URLRequest(url: WebUri(url)), settings: settings);
  }

  static Future<void> openWindowsWebview(String url) async {
    FlutterWindowsWebview().launchWebview(url);
  }
}
