import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../common.dart';

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
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: false,
    javaScriptEnabled: false,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: false,
    underPageBackgroundColor: Colors.white,
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
