import 'package:flutter/widgets.dart';
import 'package:lantern/messaging/widgets/reply/reply_mime.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/reply/reply_snippet_header.dart';
import 'package:lantern/messaging/widgets/reply/reply_snippet_deleted.dart';
import 'package:lantern/messaging/widgets/reply/reply_snippet_text.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

class ReplyPreview extends StatelessWidget {
  const ReplyPreview({
    Key? key,
    this.quotedMessage,
    required this.model,
    required this.onCloseListener,
    required this.contact,
  }) : super(key: key);

  final StoredMessage? quotedMessage;
  final MessagingModel model;
  final Function onCloseListener;
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final isNotNullorDeleted =
        (quotedMessage != null && quotedMessage!.remotelyDeletedAt == 0);
    final mimeType = isNotNullorDeleted && quotedMessage!.attachments.isNotEmpty
        ? quotedMessage!.attachments[0]!.attachment.mimeType.split('/')[0]
        : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                fit: FlexFit.tight,
                child:
                    ReplySnippetHeader(msg: quotedMessage!, contact: contact),
              ),
              Flexible(
                child: GestureDetector(
                  onTap: () => onCloseListener(),
                  child: const Icon(Icons.close, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  mimeType,
                  style: tsReplySnippetSpecialCase,
                ),
                quotedMessage!.attachments.isEmpty
                    ? ReplySnippetText(quotedMessage: quotedMessage)
                    : ReplyMime(storedMessage: quotedMessage!, model: model),
              ]),
        ],
      ),
    );
  }
}
