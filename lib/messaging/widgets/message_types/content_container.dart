import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lantern/messaging/widgets/attachment.dart';
import 'package:lantern/messaging/widgets/message_types/contact_connection_card.dart';
import 'package:lantern/messaging/widgets/message_types/status_row.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/messaging/widgets/reply/reply_snippet.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/message_position.dart';
import 'package:lantern/utils/show_alert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ContentContainer extends StatelessWidget {
  final bool outbound;
  final bool inbound;
  final StoredMessage msg;
  final StoredMessage? priorMessage;
  final StoredMessage? nextMessage;
  final PathAndValue<StoredMessage> message;
  final Contact contact;
  final Function(PathAndValue<StoredMessage>) onTapReply;
  final bool startOfBlock;
  final bool endOfBlock;
  final bool newestMessage;
  final Map<String, List<dynamic>> reactions;
  final bool isAttachment;

  const ContentContainer(
    this.priorMessage,
    this.nextMessage,
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
    Widget? reactionsList;
    Widget? nextReaction;
    final attachments = msg.attachments.values
        .map((attachment) => attachmentWidget(attachment, inbound));

    final isAudio = msg.attachments.values.any(
        (attachment) => audioMimes.contains(attachment.attachment.mimeType));
    final isContactConnectionCard = msg.hasIntroduction();
    final reactions = constructReactionsMap(msg, contact);
    reactionsList = constructReactionsList(context, reactions, msg);
    if (nextMessage != null) {
      nextReaction = constructReactionsList(
          context, constructReactionsMap(nextMessage!, contact), nextMessage!);
    }
    return Container(
      constraints: BoxConstraints(
          minWidth: 1,
          maxWidth: MediaQuery.of(context).size.width * .8,
          minHeight: 1),
      clipBehavior: Clip.none,
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
        //OUTBOUND: SENDED MESSAGES.
        //INBOUND: RECEIVED MESSAGES
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(
            MessagePosition.topLeftBorder(
                reactionsList, nextMessage, priorMessage, inbound, outbound),
          ),
          bottomStart: Radius.circular(
            MessagePosition.bottomLeftBorder(reactionsList, nextReaction,
                nextMessage, priorMessage, inbound, outbound),
          ),
          topEnd: Radius.circular(
            MessagePosition.topRightBorder(
                reactionsList, nextMessage, priorMessage, inbound, outbound),
          ),
          bottomEnd: Radius.circular(
            MessagePosition.bottomRightBorder(
                reactionsList, nextMessage, priorMessage, inbound, outbound),
          ),
        ),
      ),
      child: isContactConnectionCard
          ? ContactConnectionCard(contact, inbound, outbound, msg, message)
          : Column(
              crossAxisAlignment:
                  outbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: MarkdownBody(
                          data: '${msg.text}',
                          onTapLink:
                              (String text, String? href, String title) async {
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
                            a: tsMessageBody(outbound)
                                .copyWith(decoration: TextDecoration.underline),
                            p: tsMessageBody(outbound),
                          ),
                        ),
                      ),
                    ]),
                  Stack(
                    clipBehavior: Clip.none,
                    fit: StackFit.loose,
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
                            StatusRow(
                              outbound,
                              inbound,
                              msg,
                              message,
                            )
                          ]),
                    ],
                  )
                ]),
    );
  }
}

typedef BubbleReactionCallback = void Function();
