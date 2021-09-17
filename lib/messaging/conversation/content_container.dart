import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lantern/messaging/conversation/attachments/attachment.dart';
import 'package:lantern/messaging/conversation/contact_connection_card.dart';
import 'package:lantern/messaging/conversation/replies/reply_snippet.dart';
import 'package:lantern/messaging/conversation/status_row.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:url_launcher/url_launcher.dart';

import 'mime_types.dart';

class ContentContainer extends StatelessWidget {
  final bool outbound;
  final bool inbound;
  final StoredMessage msg;
  final PathAndValue<StoredMessage> message;
  final Contact contact;
  final Function(PathAndValue<StoredMessage>) onTapReply;
  final bool startOfBlock;
  final bool endOfBlock;
  final bool newestMessage;
  final Map<String, List<dynamic>> reactions;
  final bool isAttachment;

  const ContentContainer(
    this.outbound,
    this.inbound,
    this.msg,
    this.message,
    this.contact,
    this.onTapReply,
    this.startOfBlock,
    this.endOfBlock,
    this.newestMessage,
    this.reactions,
    this.isAttachment,
  ) : super();

  @override
  Widget build(BuildContext context) {
    final reactionsList = constructReactionsList(context, reactions, msg);
    final attachments = msg.attachments.values
        .map((attachment) => attachmentWidget(attachment, inbound));

    final isAudio = msg.attachments.values.any(
        (attachment) => audioMimes.contains(attachment.attachment.mimeType));
    final isContactConnectionCard = msg.hasIntroduction();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          constraints: BoxConstraints(
              minWidth: 1, maxWidth: constraints.maxWidth * 0.8, minHeight: 1),
          clipBehavior: Clip.hardEdge,
          padding: EdgeInsets.only(
              top: msg.replyToId.isNotEmpty ? 8 : 0,
              bottom: 8,
              left: isAttachment ? 0 : 8,
              right: isAttachment ? 0 : 8),
          decoration: BoxDecoration(
            color: outbound ? outboundBgColor : inboundBgColor,
            border: isAttachment && !isAudio
                ? Border.all(color: grey4, width: 0.5)
                : null,
            borderRadius: BorderRadius.only(
              topLeft: inbound
                  ? endOfBlock
                      ? Radius.circular(startOfBlock ? 8 : 1)
                      : const Radius.circular(8)
                  : const Radius.circular(8),
              topRight: outbound
                  ? endOfBlock
                      ? Radius.circular(startOfBlock ? 8 : 1)
                      : const Radius.circular(8)
                  : const Radius.circular(8),
              bottomRight: outbound
                  ? startOfBlock
                      ? const Radius.circular(1)
                      : const Radius.circular(8)
                  : const Radius.circular(8),
              bottomLeft: inbound
                  ? startOfBlock
                      ? const Radius.circular(1)
                      : const Radius.circular(8)
                  : const Radius.circular(8),
            ),
          ),
          child: isContactConnectionCard
              ? ContactConnectionCard(
                  contact, inbound, outbound, msg, message, reactionsList)
              : Column(
                  crossAxisAlignment: outbound
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (msg.replyToId.isNotEmpty)
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () => onTapReply(message),
                              child: ReplySnippet(outbound, msg, contact),
                            ),
                        ],
                      ),
                      if (msg.text.isNotEmpty)
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: MarkdownBody(
                                data: '${msg.text}',
                                onTapLink: (String text, String? href,
                                    String title) async {
                                  if (href != null && await canLaunch(href)) {
                                    showAlertDialog(
                                        context: context,
                                        title: CText('open_url'.i18n,
                                            style: tsBody3),
                                        content: CTextWrap(
                                            'are_you_sure_you_want_to_open'
                                                .fill([href]),
                                            style: tsBody),
                                        dismissText: 'cancel'.i18n,
                                        agreeText: 'continue'.i18n,
                                        agreeAction: () async {
                                          await launch(href);
                                        });
                                  }
                                },
                                styleSheet: MarkdownStyleSheet(
                                  a: tsBody3.copiedWith(
                                      color: outbound
                                          ? outboundMsgColor
                                          : inboundMsgColor,
                                      decoration: TextDecoration.underline),
                                  p: tsBody3.copiedWith(
                                      color: outbound
                                          ? outboundMsgColor
                                          : inboundMsgColor),
                                ),
                              ),
                            ),
                          ),
                        ]),
                      Stack(
                        fit: StackFit.passthrough,
                        alignment: outbound
                            ? AlignmentDirectional.bottomEnd
                            : AlignmentDirectional.bottomStart,
                        children: [
                          ...attachments,
                          Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: outbound
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                StatusRow(outbound, inbound, msg, message,
                                    reactionsList)
                              ]),
                        ],
                      )
                    ]),
        );
      },
    );
  }
}
