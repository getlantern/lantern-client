import 'package:auto_route/auto_route.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/core/router/router.gr.dart';

class Introducing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tsCustomButton = CTextStyle(
      fontSize: 14,
      lineHeight: 14,
      fontWeight: FontWeight.w500,
    );
    final tsDisplayItalic = CTextStyle(
      fontSize: 30,
      lineHeight: 36,
      color: white,
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.italic,
    );
    return showFullscreenDialog(
      context: context,
      onCloseCallback: () => context.router.pop(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: Container(
              padding: const EdgeInsetsDirectional.only(top: 24.0, bottom: 24),
              child: CAssetImage(
                  path: ImagePaths.introducing_illustration,
                  size: MediaQuery.of(context).size.height),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              color: blue4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        top: 32.0, bottom: 16.0),
                    child: CText('introducing'.i18n,
                        style: tsDisplayItalic, textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 40.0, end: 40.0, bottom: 40.0),
                    child: CText(
                      'introducing_des'.i18n,
                      style: tsBody1.copiedWith(color: white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 40, end: 40, bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () {},
                            child: CText(
                              'maybe_later'.i18n.toUpperCase(),
                              style: tsCustomButton.copiedWith(color: white),
                            )),
                        TextButton(
                            onPressed: () {},
                            child: CText(
                              'try'.i18n.toUpperCase(),
                              style: tsCustomButton.copiedWith(color: yellow3),
                            )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
