import 'package:lantern/messaging/messaging.dart';

class ConversationSticker extends StatelessWidget {
  final Contact contact;
  final bool isPendingIntroduction;

  const ConversationSticker({
    Key? key,
    required this.contact,
    required this.isPendingIntroduction,
  }) : super(key: key);

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
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        !isPendingIntroduction ? _fullyAddedIcon() : _partiallyAddedIcon(),
        Column(
          children: [
            Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 16, top: 8, bottom: 8),
                child: !isPendingIntroduction
                    ? _fullyAddedText()
                    : _partiallyAddedText()),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 8.0),
            //   child: CText(source, style: tsBody2.copiedWith(color: grey5)),
            // ),
          ],
        ),
      ],
    );
  }

  CText _partiallyAddedText() {
    return CText('banner_intro_waiting'.i18n.fill([contact.displayName]),
        style: tsBody2.copiedWith(color: grey5), textAlign: TextAlign.center);
  }

  Icon _partiallyAddedIcon() {
    return const Icon(Icons.more_horiz_rounded, size: 18, color: Colors.black);
  }

  CText _fullyAddedText() {
    return contact.messagesDisappearAfterSeconds > 0
        ? CText(
            'banner_messages_disappear'.i18n.fill([
              contact.messagesDisappearAfterSeconds
                  .humanizeSeconds(longForm: true)
            ]),
            style: tsBody2.copiedWith(color: grey5))
        : CText('banner_messages_persist'.i18n,
            style: tsBody2.copiedWith(color: grey5));
  }

  Icon _fullyAddedIcon() {
    return contact.messagesDisappearAfterSeconds > 0
        ? const Icon(Icons.timer, size: 18, color: Colors.black)
        : const Icon(Icons.lock_clock, size: 18, color: Colors.black);
  }
}
