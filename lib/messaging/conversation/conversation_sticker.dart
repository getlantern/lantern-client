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
    var source = 'banner_source_unknown'.i18n;
    switch (contact.source) {
      case ContactSource.APP1:
        source = 'banner_source_qr'.i18n;
        break;
      case ContactSource.APP2:
        source = 'banner_source_id'.i18n;
        break;
      case ContactSource.INTRODUCTION:
        source = 'banner_source_intro'.i18n;
        break;
    }
    return ListTile(
      dense: true,
      minLeadingWidth: 18,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child:
            !isPendingIntroduction ? _fullyAddedIcon() : _partiallyAddedIcon(),
      ),
      title: Column(
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: !isPendingIntroduction
                  ? _fullyAddedText()
                  : _partiallyAddedText()),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            //TODO: style this per designs
            child: CText(source, style: tsBody2.copiedWith(color: grey5)),
          ),
        ],
      ),
    );
  }

  CText _partiallyAddedText() {
    return CText('banner_intro_waiting'.i18n.fill([contact.displayName]),
        style: tsBody2.copiedWith(color: grey5), textAlign: TextAlign.center);
  }

  CAssetImage _partiallyAddedIcon() {
    return const CAssetImage(
        path: ImagePaths.pending, size: 18, color: Colors.black);
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

  CAssetImage _fullyAddedIcon() {
    return contact.messagesDisappearAfterSeconds > 0
        ? const CAssetImage(
            path: ImagePaths.clock, size: 18, color: Colors.black)
        : const CAssetImage(
            path: ImagePaths.lock_clock, size: 18, color: Colors.black);
  }
}
