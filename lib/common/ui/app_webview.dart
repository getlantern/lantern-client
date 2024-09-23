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
        javaScriptEnabled: true,
        isInspectable: kDebugMode,
      ));

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
        await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
        break;
    }
  }
}
