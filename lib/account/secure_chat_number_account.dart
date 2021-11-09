import 'package:lantern/messaging/messaging.dart';

class SecureChatNumberAccount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var textCopied = false;
    final model = context.watch<MessagingModel>();
    return model
        .me((BuildContext context, Contact me, Widget? child) => BaseScreen(
            title: 'secure_chat_number'.i18n,
            body: Column(
              children: [
                StatefulBuilder(
                    builder: (context, setState) =>
                        ListItemFactory.isSettingsItem(
                          header: 'your_secure_chat_number'.i18n.toUpperCase(),
                          onTap: () async {
                            copyText(context, me.chatNumber.number);
                            setState(() => textCopied = true);
                            await Future.delayed(defaultAnimationDuration,
                                () => setState(() => textCopied = false));
                          },
                          leading: const CAssetImage(
                            path: ImagePaths.tag,
                          ),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(padding: EdgeInsets.all(4.0)),
                              Expanded(
                                child: FullChatNumberWidget(
                                    context, me.chatNumber),
                              ),
                              const Padding(padding: EdgeInsets.all(4.0)),
                            ],
                          ),
                          trailingArray: [
                            CInkWell(
                              onTap: () async {
                                copyText(context, me.chatNumber.number);
                                setState(() => textCopied = true);
                                await Future.delayed(defaultAnimationDuration,
                                    () => setState(() => textCopied = false));
                              },
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    start: 16.0),
                                child: CAssetImage(
                                  path: textCopied
                                      ? ImagePaths.check_green
                                      : ImagePaths.content_copy,
                                ),
                              ),
                            )
                          ],
                        )),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.only(top: 16.0, bottom: 16.0),
                  child: CText('secure_text_explanation_account'.i18n,
                      style: tsBody1.copiedWith(color: grey5)),
                ),
              ],
            )));
  }
}
