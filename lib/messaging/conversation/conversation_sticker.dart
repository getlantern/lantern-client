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
    return ListTile(
      dense: true,
      minLeadingWidth: 18,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child:
            !isPendingIntroduction ? _fullyAddedIcon() : _partiallyAddedIcon(),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child:
            !isPendingIntroduction ? _fullyAddedText() : _partiallyAddedText(),
      ),
    );
  }

  CTextWrap _partiallyAddedText() {
    return CTextWrap('banner_intro_waiting'.i18n.fill([contact.displayName]),
        style: tsBody2.copiedWith(color: grey5), textAlign: TextAlign.center);
  }

  Icon _partiallyAddedIcon() {
    return const Icon(Icons.more_horiz_rounded, size: 18, color: Colors.black);
  }

  CTextWrap _fullyAddedText() {
    return contact.messagesDisappearAfterSeconds > 0
        ? CTextWrap(
            'banner_messages_disappear'.i18n.fill([
              contact.messagesDisappearAfterSeconds
                  .humanizeSeconds(longForm: true)
            ]),
            style: tsBody2.copiedWith(color: grey5))
        : CTextWrap('banner_messages_persist'.i18n,
            style: tsBody2.copiedWith(color: grey5));
  }

  Icon _fullyAddedIcon() {
    return contact.messagesDisappearAfterSeconds > 0
        ? const Icon(Icons.timer, size: 18, color: Colors.black)
        : const Icon(Icons.lock_clock, size: 18, color: Colors.black);
  }
}
