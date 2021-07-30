import 'dart:ui';

import 'package:lantern/messaging/widgets/reply/reply_mime.dart';
import 'package:lantern/messaging/widgets/reply/reply_snippet_header.dart';
import 'package:lantern/messaging/widgets/reply/reply_snippet_description.dart';
import 'package:lantern/messaging/widgets/reply/reply_snippet_text.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:collection/collection.dart';

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
      final isTextRespose = quotedMessage?.value.attachments.isEmpty ?? false;

      return Container(
          height: 56.0,
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                  color: snippetShadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
              color: snippetBgColor),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 3.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReplySnippetHeader(msg: msg, contact: contact),
                      if (isNotNullorDeleted && isTextRespose)
                        ReplySnippetText(text: quotedMessage!.value.text),
                      if (isNotNullorDeleted && !isTextRespose)
                        ReplySnippetDescription(
                          descriptiveText: quotedMessage
                                  ?.value.attachments[0]!.attachment.mimeType
                                  .split('/')[0] ??
                              'Error fetching Message Preview'.i18n,
                        ),
                      if (!isNotNullorDeleted)
                        ReplySnippetDescription(
                          descriptiveText: 'Message was deleted'.i18n,
                        )
                    ],
                  ),
                ),
              ),
              if (isNotNullorDeleted && !isTextRespose)
                Container(
                  width: 56,
                  height: 56,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8))),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: ReplyMime(
                        storedMessage: quotedMessage!.value, model: model),
                  ),
                )
            ],
          ));
    });
  }
}
