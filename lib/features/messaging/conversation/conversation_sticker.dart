import 'package:lantern/features/messaging/messaging.dart';

import 'message_retention.dart';

class ConversationSticker extends StatelessWidget {
  final Contact contact;
  final int messageCount;

  const ConversationSticker(this.contact, this.messageCount);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: contact.isUnaccepted()
          ? null
          : calculateStickerHeight(context, messageCount),
      child: Column(
        children: [
          // ** Illustration ** //
          if (contact.isAccepted())
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
              ),
            ),
          if (contact.isAccepted())
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8, bottom: 8),
              child: CText(
                'start_of_your_history'
                    .i18n
                    .fill([contact.displayNameOrFallback]),
                style: tsBody2.copiedWith(color: grey5),
                textAlign: TextAlign.center,
              ),
            ),
          // ** Message Retention ** //
          MessageRetention(contact: contact),
        ],
      ),
    );
  }
}
