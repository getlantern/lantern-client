import 'package:lantern/messaging/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/messaging/conversation/message_utils.dart';

class ReplySnippetHeader extends StatelessWidget {
  const ReplySnippetHeader({
    Key? key,
    required this.msg,
    required this.contact,
  }) : super(key: key);

  final StoredMessage msg;
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        const Icon(
          Icons.reply,
          size: 12,
        ),
        Text(
          'Replying to ${matchIdToDisplayName(msg.replyToSenderId, contact)}',
          overflow: TextOverflow.ellipsis,
          style: tsReplySnippetHeader,
        ),
      ],
    );
  }
}
