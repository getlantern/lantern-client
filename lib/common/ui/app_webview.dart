import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_windows_webview/flutter_windows_webview.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/common_desktop.dart';
import 'package:lantern/plans/utils.dart';

@RoutePage(name: 'AppWebview')
class AppWebView extends StatefulWidget {
  final String url;

  const AppWebView({
    super.key,
    required this.url,
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
      title: "",
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        initialSettings: settings,
      ),
    );
  }
}

class AppBrowser extends InAppBrowser {
  final Future<void> Function()? onClose;
  final InAppBrowserClassSettings settings = InAppBrowserClassSettings(
      browserSettings: InAppBrowserSettings(hideUrlBar: true),
      webViewSettings: InAppWebViewSettings(
          javaScriptEnabled: true, isInspectable: kDebugMode));

  AppBrowser({
    required this.onClose,
  });

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
    this.onClose?.call();
  }

  @override
  void onReceivedError(WebResourceRequest request, WebResourceError error) {
    print("Can't load ${request.url}.. Error: ${error.description}");
  }

  @override
  void onProgressChanged(progress) {
    print("Progress: $progress");
  }

  @override
  void onExit() {
    print("Browser closed");
  }

  Future<void> openMacWebview(String url) async {
    await this.openUrlRequest(
        urlRequest: URLRequest(url: WebUri(url)), settings: settings);
  }

  static Future<void> openWindowsWebview(String url) async {
    FlutterWindowsWebview().launchWebview(url);
  }
}
