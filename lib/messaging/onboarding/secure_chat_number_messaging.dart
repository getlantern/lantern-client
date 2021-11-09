import 'package:lantern/home.dart';

import '../messaging.dart';

class SecureChatNumberMessaging extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var textCopied = false;
    final model = context.watch<MessagingModel>();
    return model
        .me((BuildContext context, Contact me, Widget? child) => BaseScreen(
            title: 'secure_chat_number'.i18n,
            body: PinnedButtonLayout(
                content: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsetsDirectional.only(
                            start: 4, top: 21, bottom: 3),
                        child: CText(
                            'your_secure_chat_number'.i18n.toUpperCase(),
                            maxLines: 1,
                            style: tsOverline),
                      ),
                      const CDivider(),
                      //* Your Secure Chat Number
                      StatefulBuilder(
                          builder: (context, setState) =>
                              ListItemFactory.isSettingsItem(
                                onTap: () async {
                                  copyText(context, me.chatNumber.shortNumber);
                                  setState(() => textCopied = true);
                                  await Future.delayed(defaultAnimationDuration,
                                      () => setState(() => textCopied = false));
                                },
                                leading: const CAssetImage(
                                  path: ImagePaths.tag,
                                ),
                                content: CText(
                                  me.chatNumber.shortNumber.formattedChatNumber,
                                  style: tsHeading1.copiedWith(
                                      color: blue4,
                                      lineHeight:
                                          24), // small hack to fix vertical offset, size it like leading/trailing icon
                                ),
                                trailingArray: [
                                  CInkWell(
                                    onTap: () async {
                                      copyText(
                                          context, me.chatNumber.shortNumber);
                                      setState(() => textCopied = true);
                                      await Future.delayed(
                                          defaultAnimationDuration,
                                          () => setState(
                                              () => textCopied = false));
                                    },
                                    child: CAssetImage(
                                      path: textCopied
                                          ? ImagePaths.check_green
                                          : ImagePaths.content_copy,
                                    ),
                                  )
                                ],
                              )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        top: 16.0, bottom: 16.0),
                    child:
                        CText('secure_text_explanation'.i18n, style: tsBody1),
                  ),
                  // // *
                  // // * DEV
                  // // *
                  // model.getOnBoardingStatus((context, value, child) => Padding(
                  //       padding: const EdgeInsets.all(8.0),
                  //       child: Button(
                  //         tertiary: true,
                  //         text: 'DEV - toggle value'.i18n,
                  //         width: 200.0,
                  //         onPressed: () async {
                  //           await model.overrideOnBoarded(!value);
                  //           context.router.popUntilRoot();
                  //         },
                  //       ),
                  //     )),
                ],
                button: Button(
                  text: 'Next'.i18n,
                  width: 200.0,
                  onPressed: () async {
                    await model.markIsOnboarded();
                    context.router.popUntilRoot();
                  },
                ))));
  }
}
