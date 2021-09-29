import 'package:lantern/messaging/messaging.dart';

class ReplySnippetHeader extends StatelessWidget {
  final StoredMessage message;
  final Contact contact;
  final bool showIcon;

  const ReplySnippetHeader({
    Key? key,
    required this.message,
    required this.contact,
    this.showIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (showIcon)
          const Padding(
            padding: EdgeInsetsDirectional.only(end: 4),
            child: CAssetImage(
              path: ImagePaths.reply,
              size: 16,
            ),
          ),
        CText(
          'replying_to'
              .i18n
              .fill([replyToDisplayName(message.senderId, contact)]),
          maxLines: 1,
          style: tsSubtitle2,
        ),
      ],
    );
  }

  String replyToDisplayName(String contactIdToMatch, Contact contact) {
    return contactIdToMatch == contact.contactId.id
        ? contact.displayName
        : 'me'.i18n;
  }
}
