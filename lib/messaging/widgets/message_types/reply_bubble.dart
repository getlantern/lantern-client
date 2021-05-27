import 'dart:ui';

import 'package:lantern/messaging/widgets/message_types/deleted_bubble.dart';
import 'package:lantern/messaging/widgets/message_types/reply_content_row.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/messaging/messaging_model.dart';

class ReplyBubble extends StatelessWidget {
  final bool outbound;
  final StoredMessage msg;
  final Contact contact;

  const ReplyBubble(
    this.outbound,
    this.msg,
    this.contact,
  ) : super();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MessagingModel>();
    return Container(
        constraints: const BoxConstraints(minWidth: 100),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.reply,
                  size: 14,
                ),
                Text(
                  matchIdToDisplayName(msg.replyToSenderId, contact),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black, // TODO: generalize in theme
                  ),
                ),
              ],
            ),
            model.contactMessages(contact, builder: (context,
                Iterable<PathAndValue<StoredMessage>> messageRecords,
                Widget? child) {
              try {
                final quotedMessage = messageRecords
                    .firstWhere((element) => element.value.id == msg.replyToId);
                return ReplyContentRow(
                    quotedMessage: quotedMessage.value,
                    outbound: outbound,
                    model: model);
              } catch (e) {
                return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: DeletedBubble());
              }
            }),
          ],
        ));
  }
}
