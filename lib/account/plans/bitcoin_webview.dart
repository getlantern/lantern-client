import 'package:lantern/common/common.dart';

class BitcoinWebview extends StatelessWidget {
  const BitcoinWebview({
    Key? key,
    required this.btcPayURL,
    required this.context,
  }) : super(key: key);

  final String btcPayURL;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.9,
          // TODO: WIP
          child: WebView(
            initialUrl: btcPayURL,
            javascriptMode: JavascriptMode.unrestricted,
            onProgress: (int progress) {
              print('WebView is loading (progress : $progress%)');
            },
            onPageStarted: (String url) {
              print('WebView started loading: $url');
            },
            onPageFinished: (String url) {
              print('PWebViewage finished loading: $url');
              context.loaderOverlay.hide();
            },
            gestureNavigationEnabled: true,
          ),
        )
      ],
    );
  }
}
