import 'package:lantern/features/messaging/messaging.dart';

@RoutePage(name: 'ChatNumberMessaging')
class ChatNumberMessaging extends StatelessWidget {
  ChatNumberMessaging() : super() {
    messagingModel.dismissTryLanternChatBadge();
  }

  @override
  Widget build(BuildContext context) {
    var textCopied = false;
    return messagingModel.me(
      (BuildContext context, Contact me, Widget? child) => BaseScreen(
        title: 'chat_number'.i18n,
        body: PinnedButtonLayout(
          content: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsetsDirectional.only(
                    start: 4,
                    top: 21,
                    bottom: 3,
                  ),
                  child: CText(
                    'your_chat_number'.i18n.toUpperCase(),
                    maxLines: 1,
                    style: tsOverline,
                  ),
                ),
                const CDivider(),
                //* Your Lantern Chat Number
                StatefulBuilder(
                  builder: (context, setState) => ListItemFactory.settingsItem(
                    onTap: () async {
                      copyText(
                        context,
                        me.chatNumber.shortNumber.formattedChatNumber,
                      );
                      setState(() => textCopied = true);
                      await Future.delayed(
                        defaultAnimationDuration,
                        () => setState(() => textCopied = false),
                      );
                    },
                    icon: ImagePaths.chatNumber,
                    content: CText(
                      me.chatNumber.shortNumber.formattedChatNumber,
                      style: tsHeading1.copiedWith(
                        color: blue4,
                        lineHeight: 24,
                      ), // small hack to fix vertical offset, size it like leading/trailing icon
                    ),
                    trailingArray: [
                      CInkWell(
                        onTap: () async {
                          copyText(
                            context,
                            me.chatNumber.shortNumber.formattedChatNumber,
                          );
                          setState(() => textCopied = true);
                          await Future.delayed(
                            defaultAnimationDuration,
                            () => setState(
                              () => textCopied = false,
                            ),
                          );
                        },
                        child: CAssetImage(
                          path: textCopied
                              ? ImagePaths.check_green
                              : ImagePaths.content_copy,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                top: 16.0,
                bottom: 16.0,
              ),
              child: CText(
                'secure_text_explanation'.i18n,
                style: tsBody1,
              ),
            ),
          ],
          button: Button(
            text: 'next'.i18n,
            onPressed: () async {
              await messagingModel.markIsOnboarded();
              context.router.popUntilRoot();
            },
          ),
        ),
      ),
    );
  }
}
