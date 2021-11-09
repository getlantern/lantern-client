import 'package:lantern/common/common.dart';
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
                                child: formatChatNumber(me.chatNumber),
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

  // TODO: format and color the short number, display the rest unformatted
  Widget formatChatNumber(ChatNumber chatNumber) {
    final short = chatNumber.shortNumber.formattedChatNumber;
    final longRemainder = chatNumber.number.split(chatNumber.shortNumber)[1];

    // APPROACH 1: use a stack and pad the start of the longRemainder string
    return Stack(children: [
      CText(short, style: tsBody2.copiedWith(color: blue4)),
      CText(longRemainder.padLeft(chatNumber.number.formattedChatNumber.length),
          style: tsBody2),
    ]);

    // APPROACH 2: use RichText
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(text: short, style: tsBody2.copyWith(color: blue4)),
          TextSpan(text: longRemainder, style: tsBody2),
        ],
      ),
    );
  }
}
