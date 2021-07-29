import 'dart:ui';

import 'package:lantern/messaging/widgets/reply/reply_mime.dart';
import 'package:lantern/messaging/widgets/reply/reply_snippet_header.dart';
import 'package:lantern/messaging/widgets/reply/reply_snippet_deleted.dart';
import 'package:lantern/messaging/widgets/reply/reply_snippet_text.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
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
              ReplySnippetHeader(msg: msg, contact: contact),
              isNotNullorDeleted
                  ? Flex(
                      direction: Axis.horizontal,
                      children: [
                        Text(
                          mimeType,
                          style: tsReplySnippetSpecialCase,
                        ),
                        quotedMessage!.value.attachments.isEmpty
                            ? ReplySnippetText(
                                quotedMessage: quotedMessage.value)
                            : ReplyMime.reply(
                                storedMessage: quotedMessage.value,
                                model: model,
                                context: context),
                      ],
                    )
                  // display deleted bubble
                  : const ReplySnippetDeleted()
            ],
          ));
    });
  }
}
