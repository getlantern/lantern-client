import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lantern/messaging/widgets/attachment.dart';
import 'package:lantern/messaging/widgets/message_types/contact_connection_card.dart';
import 'package:lantern/messaging/widgets/message_types/status_row.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/messaging/widgets/reply/reply_snippet.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/show_alert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

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
                                        title: Text('Open URL'.i18n,
                                            style: tsAlertDialogTitle),
                                        content: Text(
                                            'Are you sure you want to open $href?',
                                            style: tsAlertDialogBody),
                                        dismissText: 'Cancel'.i18n,
                                        agreeText: 'Continue'.i18n,
                                        agreeAction: () async {
                                          await launch(href);
                                        });
                                  }
                                },
                                styleSheet: MarkdownStyleSheet(
                                  a: tsMessageBody(outbound).copyWith(
                                      decoration: TextDecoration.underline),
                                  p: tsMessageBody(outbound),
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
