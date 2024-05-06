import 'package:lantern/messaging/messaging.dart';

class TryLanternChat extends StatelessWidget {
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
                  top: 40,
                ), // 24 + 16 from designs
                alignment: Alignment.centerRight,
                child: IconButton(
                  padding: const EdgeInsetsDirectional.all(0),
                  icon: Icon(
                    Icons.close_rounded,
                    color: black,
                  ),
                  onPressed: () async {
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
                child: Container(
                  padding: const EdgeInsetsDirectional.only(
                    start: 40,
                    end: 40,
                    bottom: 32,
                  ),
                  color: white,
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      // This lays out the speech bubble and lock images in
                      // pairs. The algorithm ensures the following:
                      //
                      // - speech bubble and lock are grouped in pairs
                      // - each row of layout contains at least 2 pairs
                      // - for wide screens, number of pairs per row grows to fill screen
                      // - the number of rows is limited to however many fit without clipping vertically
                      // - pairs and margins are scaled to match proportions from design

                      const iconSize = 48;
                      final horizontalMargin = 32;
                      const verticalMargin = 40;
                      final pairWidth = 2 * iconSize + 2 * horizontalMargin;
                      final pairHeight = iconSize + verticalMargin;
                      final numColumns =
                          max(2, constraints.maxWidth ~/ pairWidth);
                      final scale = constraints.maxWidth /
                          (numColumns * pairWidth).toDouble();
                      final numRows =
                          constraints.maxHeight ~/ (scale * pairHeight);
                      final count = 2 * numColumns * numRows;
                      return Container(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          spacing: horizontalMargin * scale,
                          runSpacing: verticalMargin * scale,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: List.generate(
                            count,
                            (index) => index.isEven
                                ? CAssetImage(
                                    path: ImagePaths
                                        .introducing_illustration_bubble,
                                    width: iconSize * scale,
                                    height: iconSize * scale,
                                  )
                                : CAssetImage(
                                    path: ImagePaths
                                        .introducing_illustration_lock,
                                    width: iconSize * scale,
                                    height: iconSize * scale,
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
                          top: 32.0,
                          bottom: 16.0,
                        ),
                        child: CText(
                          'introducing'.i18n,
                          style: tsDisplayItalic,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 40.0,
                          end: 40.0,
                        ),
                        child: CText(
                          'introducing_des'.i18n,
                          style: tsBody1.copiedWith(color: white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 40,
                          end: 40,
                          top: 36.0,
                        ),
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
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Switch to Chats tab
                                sessionModel.setSelectedTab(context, TAB_CHATS);
                                // Start onboarding
                                await messagingModel.start();
                                await context.router
                                    .push(const ChatNumberMessaging());
                              },
                              child: CText(
                                'try'.i18n.toUpperCase(),
                                style:
                                    tsCustomButton.copiedWith(color: yellow3),
                              ),
                            ),
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
