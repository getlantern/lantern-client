import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lantern/common/common.dart';

@RoutePage(name: 'AppWebview')
class AppWebView extends StatefulWidget {
  final String url;
  final String title;

  const AppWebView({
    super.key,
    required this.url,
    this.title = "",
  });

  @override
  State<AppWebView> createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  InAppWebViewSettings settings = InAppWebViewSettings(
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
      ),
    );
  }
}
