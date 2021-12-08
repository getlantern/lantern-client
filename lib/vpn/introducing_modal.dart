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
          height: 60,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Container(
                padding: const EdgeInsetsDirectional.only(
                    top: 40), // 24 + 16 from designs
                alignment: Alignment.centerRight,
                child: IconButton(
                  padding: const EdgeInsetsDirectional.all(0),
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
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: LayoutBuilder(
                    builder: (context, constraints) => Container(
                          color: white,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: GridView.count(
                            crossAxisCount: 5, // five columns
                            mainAxisSpacing: 24.0, // space between rows
                            crossAxisSpacing: 24.0, // space between columns
                            padding: const EdgeInsetsDirectional.all(36),
                            clipBehavior: Clip.hardEdge,
                            children: List.generate(
                                constraints.maxHeight ~/
                                    80 * // a rough estimation for each tile size
                                    5,
                                (index) => CAssetImage(
                                      path: index.isEven
                                          ? ImagePaths
                                              .introducing_illustration_bubble
                                          : ImagePaths
                                              .introducing_illustration_lock,
                                    )),
                          ),
                        )),
              ),
              Flexible(
                flex: 1,
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
                            start: 40, end: 40, top: 36.0),
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
                                  // TODO: fix
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
