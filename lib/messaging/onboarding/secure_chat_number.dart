import '../messaging.dart';

class SecureChatNumber extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var textCopied = false;
    var dummyNumber = '63751638576';
    return BaseScreen(
        title: 'secure_chat_number'.i18n,
        body: PinnedButtonLayout(
            content: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsetsDirectional.only(
                        start: 4, top: 21, bottom: 3),
                    child: CText('your_secure_chat_number'.i18n.toUpperCase(),
                        maxLines: 1, style: tsOverline),
                  ),
                  const CDivider(),
                  //* Your Secure Chat Number
                  StatefulBuilder(
                      builder: (context, setState) => CListTile(
                            onTap: () async {
                              copyText(
                                  context, dummyNumber); // TODO: use chatNumber
                              setState(() => textCopied = true);
                              await Future.delayed(defaultAnimationDuration,
                                  () => setState(() => textCopied = false));
                            },
                            leading: const CAssetImage(
                              path: ImagePaths.tag,
                            ),
                            content: CText(
                              dummyNumber,
                              // TODO: use chatNumber
                              style: tsHeading1.copiedWith(
                                  color: blue4,
                                  lineHeight:
                                      24), // small hack to fix vertical offset, size it like leading/trailing icon
                            ),
                            trailing: CInkWell(
                              onTap: () async {
                                copyText(context,
                                    dummyNumber); // TODO: use chatNumber
                                setState(() => textCopied = true);
                                await Future.delayed(defaultAnimationDuration,
                                    () => setState(() => textCopied = false));
                              },
                              child: CAssetImage(
                                path: textCopied
                                    ? ImagePaths.check_green
                                    : ImagePaths.content_copy,
                              ),
                            ),
                          )),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.only(top: 16.0, bottom: 16.0),
                child: CText('secure_text_explanation'.i18n, style: tsBody1),
              ),
            ],
            button: Button(
              text: 'Next'.i18n,
              width: 200.0,
              onPressed: () {}, // TODO: direct to Chats
            )));
  }
}
