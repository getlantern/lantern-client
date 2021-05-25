import 'dart:io';
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
                    color: !outbound
                        ? Colors.white
                        : Colors.black, // TODO: generalize in theme
                  ),
                ),
              ],
            ),
            Container(
              child: model.contactMessages(contact, builder: (context,
                  Iterable<PathAndValue<StoredMessage>> messageRecords,
                  Widget? child) {
                final quotedMessage = messageRecords
                    .firstWhere((element) => element.value.id == msg.replyToId);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (quotedMessage.value.attachments.isEmpty)
                      Text(
                        quotedMessage.value.text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: !outbound
                              ? Colors.white
                              : Colors.black, // TODO: generalize in theme
                        ),
                      ),
                    if (quotedMessage.value.attachments.isNotEmpty)
                      Row(
                        children: [
                          Text(quotedMessage
                              .value.attachments[0]!.attachment.mimeType),
                          Container(
                              child: Image.file(
                                  File(quotedMessage
                                      .value.attachments[0]!.plainTextFilePath),
                                  filterQuality: FilterQuality.high,
                                  scale: 10))
                        ],
                      )
                  ],
                );
              }),
            )
          ],
        ));
  }
}
