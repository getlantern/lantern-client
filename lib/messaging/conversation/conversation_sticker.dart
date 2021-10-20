import 'package:lantern/messaging/messaging.dart';

class ConversationSticker extends StatelessWidget {
  final Contact contact;
  final int messageCount;

  const ConversationSticker(this.contact, this.messageCount);

  @override
  Widget build(BuildContext context) {
    // var source = 'banner_source_unknown'.i18n;
    // switch (contact.source) {
    //   case ContactSource.APP1:
    //     source = 'banner_source_qr'.i18n;
    //     break;
    //   case ContactSource.APP2:
    //     source = 'banner_source_id'.i18n;
    //     break;
    //   case ContactSource.INTRODUCTION:
    //     source = 'banner_source_intro'.i18n;
    //     break;
    // }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        height: calculateStickerHeight(context, constraints, messageCount),
        child: Column(
          children: [
            // ** Illustration ** //
            Container(
                padding: const EdgeInsetsDirectional.only(top: 20, bottom: 8),
                child: Stack(
                  children: [
                    SvgPicture.asset(
                      ImagePaths.sticker_figure_background,
                    ),
                    SvgPicture.asset(
                      ImagePaths.sticker_figure_foreground,
                      color: getIllustrationColor(contact),
                    ),
                  ],
                )),
            Container(
              padding: const EdgeInsetsDirectional.only(top: 8, bottom: 8),
              child: CText(
                  'start_of_your_history'
                      .i18n
                      .fill([contact.displayNameOrFallback]),
                  style: tsBody2.copiedWith(color: grey5)),
            ),
            // ** Message Retention ** //
            Container(
              padding: const EdgeInsetsDirectional.only(top: 8, bottom: 20),
              child: FittedBox(
                fit: BoxFit.none,
                child: Container(
                  decoration: BoxDecoration(
                      color: white,
                      border: Border.all(color: grey3),
                      borderRadius: const BorderRadius.all(
                          Radius.circular(borderRadius))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        contact.messagesDisappearAfterSeconds > 0
                            ? const CAssetImage(
                                path: ImagePaths.timer, color: Colors.black)
                            : const CAssetImage(
                                path: ImagePaths.lock_clock,
                                color: Colors.black),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                  start: 16, top: 8, bottom: 8),
                              child: contact.messagesDisappearAfterSeconds > 0
                                  ? CText(
                                      'banner_message_retention'.i18n.fill([
                                        contact.messagesDisappearAfterSeconds
                                            .humanizeSeconds(longForm: true)
                                      ]),
                                      style: tsBody2.copiedWith(color: grey5))
                                  : CText('banner_messages_persist'.i18n,
                                      style: tsBody2.copiedWith(color: grey5)),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                            //   child: CText(source, style: tsBody2.copiedWith(color: grey5)),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
