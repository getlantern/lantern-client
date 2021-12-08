import 'package:lantern/messaging/messaging.dart';

class IntroducingModal extends StatelessWidget {
  final BuildContext autorouterContext;

  IntroducingModal({
    required this.autorouterContext,
  });

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

  @override
  Widget build(BuildContext context) {
    var messagingModel = context.watch<MessagingModel>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          color: white,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Container(
                padding: const EdgeInsetsDirectional.only(
                    top: 40), // 24 + 16 from designs
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: black,
                  ),
                  onPressed: () async {
                    await messagingModel.saveFirstSeenIntroducingTS();
                    await context.router.pop();
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Flexible(
                child: Container(
                  color: white,
                  padding: const EdgeInsetsDirectional.only(bottom: 24),
                  child: CAssetImage(
                    path: ImagePaths.introducing_illustration,
                    size: MediaQuery.of(context).size.height,
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  color: blue4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                            top: 32.0, bottom: 16.0),
                        child: CText('introducing'.i18n,
                            style: tsDisplayItalic,
                            textAlign: TextAlign.center),
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
                                  await messagingModel
                                      .saveFirstSeenIntroducingTS();
                                  await context.router.pop();
                                },
                                child: CText(
                                  'maybe_later'.i18n.toUpperCase(),
                                  style:
                                      tsCustomButton.copiedWith(color: white),
                                )),
                            TextButton(
                                onPressed: () async {
                                  await messagingModel
                                      .saveFirstAccessedChatTS();
                                  await messagingModel
                                      .saveFirstSeenIntroducingTS();
                                  await context.router.pop();
                                  // See https://github.com/Milad-Akarie/auto_route_library#finding-the-right-router
                                  autorouterContext.tabsRouter.setActiveIndex(
                                      0); // index 0 for Chats tab
                                  autorouterContext.innerRouterOf<TabsRouter>(
                                      SecureNumberRecovery.name);
                                },
                                child: CText(
                                  'try'.i18n.toUpperCase(),
                                  style:
                                      tsCustomButton.copiedWith(color: yellow3),
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
        )
      ],
    );
  }
}
