import 'package:auto_route/auto_route.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/messaging.dart';

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
    final model = context.watch<MessagingModel>();
    return showFullscreenDialog(
      context: context,
      onCloseCallback: () async {
        await context.router.pop();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: Container(
              padding: const EdgeInsetsDirectional.only(bottom: 24),
              child: CAssetImage(
                path: ImagePaths.introducing_illustration,
                size: MediaQuery.of(context).size.width,
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              color: blue4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                        start: 40.0, end: 40.0),
                    child: CText(
                      'introducing_des'.i18n,
                      style: tsBody1.copiedWith(color: white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 40, end: 40, top: 36.0, bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () async {
                              await context.router.pop();
                            },
                            child: CText(
                              'maybe_later'.i18n.toUpperCase(),
                              style: tsCustomButton.copiedWith(color: white),
                            )),
                        TextButton(
                            onPressed: () async {
                              await model.saveFirstAccessedChatTS();
                              // TODO: switch to Chats tab
                            },
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
