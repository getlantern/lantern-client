import 'dart:ui';

import 'package:lantern/enums/mime_reply.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:collection/collection.dart';
import 'package:sizer/sizer.dart';

class ReplySnippet extends StatelessWidget {
  final bool outbound;
  final StoredMessage msg;
  final Contact contact;

  const ReplySnippet(
    this.outbound,
    this.msg,
    this.contact,
  ) : super();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MessagingModel>();
    return model.contactMessages(contact, builder: (context,
        Iterable<PathAndValue<StoredMessage>> messageRecords, Widget? child) {
      final quotedMessage = messageRecords
          .firstWhereOrNull((element) => element.value.id == msg.replyToId);
      final humanizedSenderName =
          matchIdToDisplayName(msg.remotelyDeletedBy.id, contact);
      final isNotNullorDeleted =
          (quotedMessage != null && quotedMessage.value.remotelyDeletedAt == 0);
      final mimeType =
          isNotNullorDeleted && quotedMessage!.value.attachments.isNotEmpty
              ? quotedMessage.value.attachments[0]!.attachment.mimeType
                  .split('/')[0]
              : '';

      return Container(
          height: 56.0,
          constraints: BoxConstraints(maxWidth: 65.w),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
              color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.reply,
                    size: 12,
                  ),
                  Text(
                    matchIdToDisplayName(msg.replyToSenderId, contact),
                    overflow: TextOverflow.ellipsis,
                    style: tsReplySnippetHeader,
                  ),
                ],
              ),
              isNotNullorDeleted
                  ? Flex(
                      direction: Axis.horizontal,
                      children: [
                        Text(
                          mimeType,
                          style: tsReplySnippetSpecialCase,
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Container(
                            height: 30.0,
                            child: MimeReply.reply(
                                storedMessage: quotedMessage!.value,
                                model: model,
                                context: context),
                          ),
                        )
                      ],
                    )
                  // display deleted bubble
                  : Text('Message deleted'.i18n,
                      style: tsReplySnippetSpecialCase)
            ],
          ));
    });
  }
}
