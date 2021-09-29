import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lantern/messaging/conversation/attachments/attachment.dart';
import 'package:lantern/messaging/conversation/contact_connection_card.dart';
import 'package:lantern/messaging/conversation/replies/reply_snippet.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:url_launcher/url_launcher.dart';

import 'mime_types.dart';
import 'reactions.dart';
import 'status_row.dart';

class MessageBubble extends StatelessWidget {
  static const rounded = Radius.circular(16);
  static const squared = Radius.zero;

  final StoredMessage message;
  final void Function() onEmojiTap;
  final Contact contact;
  final void Function() onReply;
  final void Function() onTapReply;

  late final bool isOutbound;
  late final bool isInbound;
  late final bool isStartOfBlock;
  late final bool isEndOfBlock;
  late final bool isNewestMessage;
  late final bool wasDeleted;
  late final bool isAttachment;
  late final bool hasReactions;
  late final Color color;
  late final Color backgroundColor;

  MessageBubble({
    Key? key,
    required this.message,
    StoredMessage? priorMessage,
    StoredMessage? nextMessage,
    required this.contact,
    required this.onReply,
    required this.onTapReply,
    required this.onEmojiTap,
  }) : super(key: key) {
    isOutbound = message.direction == MessageDirection.OUT;
    isInbound = !isOutbound;
    isStartOfBlock =
        priorMessage == null || priorMessage.direction != message.direction;
    isEndOfBlock =
        nextMessage == null || nextMessage.direction != message.direction;
    isNewestMessage = nextMessage == null;
    wasDeleted = message.remotelyDeletedAt != 0;
    isAttachment = message.attachments.isNotEmpty;
    hasReactions = message.reactions.isNotEmpty;
    color = isOutbound ? outboundMsgColor : inboundMsgColor;
    backgroundColor = isOutbound ? outboundBgColor : inboundBgColor;
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MessagingModel>();

    if (message.firstViewedAt == 0) {
      model.markViewed(message);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          isOutbound ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
                top: isStartOfBlock || hasReactions ? 8 : 2,
                bottom: isNewestMessage ? 8 : 0),
            child: overlayReactions(context, bubble(context, model)),
          ),
        ),
      ],
    );
  }

  Widget bubble(BuildContext context, MessagingModel model) {
    return FocusedMenuHolder(
      menuWidth: maxBubbleWidth(context),
      onPressed: () {},
      menu: messageMenu(context, model),
      child: Column(
        crossAxisAlignment:
            isOutbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          content(context),
        ],
      ),
    );
  }

  Widget overlayReactions(BuildContext context, Widget child) {
    if (!hasReactions) {
      return child;
    }

    final counts = countReactions();
    var width = 24.0;
    var children = <Widget>[
      CText(counts.keys.first, style: tsEmoji),
    ];
    if (counts.length == 2) {
      width = 44.0;
      children.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 2),
          child: CText(counts.keys.last, style: tsEmoji),
        ),
      );
    } else if (counts.containsValue(2)) {
      width = 44.0;
      children.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 2),
          child: CText(counts.values.first.toString(), style: tsEmoji),
        ),
      );
    }

    final padding = width / 2;

    final reactionsWidget = SizedBox(
      width: width,
      height: 24,
      child: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center, children: children),
      ),
    );

    return Stack(
      alignment: isOutbound ? Alignment.topLeft : Alignment.topRight,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
              top: 12,
              start: isOutbound ? padding : 0,
              end: isInbound ? padding : 0),
          child: child,
        ),
        reactionsWidget,
      ],
    );
  }

  Widget content(BuildContext context) {
    assert(message.attachments.values.length <= 1,
        'display of messages with multiple attachments is unsupported');

    final attachment = message.attachments.isEmpty
        ? null
        : attachmentWidget(
            contact, message, message.attachments.values.first, isInbound);

    final isAudio = message.attachments.values.any(
        (attachment) => audioMimes.contains(attachment.attachment.mimeType));
    final isContactConnectionCard = message.hasIntroduction();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return wrapBubble(
          context,
          isAudio,
          isContactConnectionCard
              ? ContactConnectionCard(contact, isInbound, isOutbound, message)
              : Column(
                  crossAxisAlignment: isOutbound
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (message.replyToId.isNotEmpty)
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () => onTapReply(),
                              child: ReplySnippet(isOutbound, message, contact),
                            ),
                        ],
                      ),
                      if (wasDeleted)
                        CText(
                            'message_deleted'.i18n.fill([
                              message.remotelyDeletedBy.id ==
                                      contact.contactId.id
                                  ? contact.displayName
                                  : 'me'.i18n
                            ]),
                            style: tsSubtitle1),
                      if (message.text.isNotEmpty)
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: Container(
                              padding: const EdgeInsetsDirectional.only(
                                  start: 8, end: 8, top: 4, bottom: 4),
                              child: MarkdownBody(
                                data: '${message.text}',
                                onTapLink: (String text, String? href,
                                    String title) async {
                                  if (href != null && await canLaunch(href)) {
                                    showConfirmationDialog(
                                        context: context,
                                        title: 'open_url'.i18n,
                                        explanation:
                                            'are_you_sure_you_want_to_open'
                                                .fill([href]),
                                        dismissText: 'cancel'.i18n,
                                        agreeText: 'continue'.i18n,
                                        agreeAction: () async {
                                          await launch(href);
                                        });
                                  }
                                },
                                styleSheet: MarkdownStyleSheet(
                                  a: tsBody3.copiedWith(
                                      color: color,
                                      decoration: TextDecoration.underline),
                                  p: tsBody3.copiedWith(color: color),
                                ),
                              ),
                            ),
                          ),
                        ]),
                      Stack(
                        fit: StackFit.passthrough,
                        alignment: isOutbound
                            ? AlignmentDirectional.bottomEnd
                            : AlignmentDirectional.bottomStart,
                        children: [
                          if (attachment != null) attachment,
                          Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: isOutbound
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                StatusRow(isOutbound, message),
                              ]),
                        ],
                      )
                    ]),
        );
      },
    );
  }

  Widget wrapBubble(BuildContext context, bool isAudio, Widget child) {
    if (wasDeleted) {
      return DottedBorder(
        color: grey3,
        radius: const Radius.circular(8),
        dashPattern: [3],
        strokeWidth: 1,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: EdgeInsetsDirectional.only(
                top: message.replyToId.isNotEmpty ? 8 : 0,
                start: isAttachment ? 0 : 8,
                end: isAttachment ? 0 : 8),
            child: child,
          ),
        ),
      );
    }
    return Container(
      constraints: BoxConstraints(
          minWidth: 1, maxWidth: maxBubbleWidth(context), minHeight: 1),
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsetsDirectional.only(
          top: message.replyToId.isNotEmpty ? 8 : 0,
          start: isAttachment ? 0 : 8,
          end: isAttachment ? 0 : 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: isAttachment && !isAudio
            ? Border.all(color: grey4, width: 0.5)
            : null,
        borderRadius: BorderRadius.only(
          topLeft: isInbound && !isStartOfBlock ? squared : rounded,
          topRight: isOutbound && !isStartOfBlock ? squared : rounded,
          bottomLeft: isInbound && (isNewestMessage || !isEndOfBlock)
              ? squared
              : rounded,
          bottomRight: isOutbound && (isNewestMessage || !isEndOfBlock)
              ? squared
              : rounded,
        ),
      ),
      child: child,
    );
  }

  SizedBox messageMenu(BuildContext context, MessagingModel model) {
    var textCopied = false;
    var height = 219.0;
    if (isOutbound) height += 48;
    if (!isAttachment) height += 48;

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 80,
              child: Reactions(
                message: message,
                model: model,
                onEmojiTap: onEmojiTap,
              ),
            ),
            const CDivider(),
            CListTile(
              height: 48,
              showDivider: false,
              leading: ImagePaths.reply,
              content: 'reply'.i18n,
              onTap: onReply,
            ),
            if (!isAttachment)
              StatefulBuilder(
                key: ValueKey(message.id),
                builder: (context, setState) => CListTile(
                  height: 48,
                  showDivider: false,
                  leading: textCopied
                      ? ImagePaths.check_green
                      : ImagePaths.content_copy,
                  content: 'copy_text'.i18n,
                  onTap: () {
                    copyText(context);
                    setState(() {
                      textCopied = true;
                    });
                  },
                ),
              ),
            CListTile(
              height: 48,
              showDivider: false,
              leading: ImagePaths.delete,
              content: 'delete_for_me'.i18n,
              onTap: () => deleteForMe(context, model),
            ),
            if (isOutbound)
              CListTile(
                height: 48,
                showDivider: false,
                leading: ImagePaths.delete,
                content: 'delete_for_everyone'.i18n,
                onTap: () => deleteForEveryone(context, model),
              ),
            const CDivider(),
            if (message.disappearAt > 0)
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: HumanizedDate.fromMillis(
                    message.disappearAt.toInt(),
                    builder: (context, date) => CText(
                      'message_will_disappear_at'.i18n.fill([date]),
                      // TODO: use long form humanization like "today at 11:56"
                      style: tsBody2.copiedWith(
                          color: grey5, lineHeight: tsBody2.fontSize),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void copyText(BuildContext context) {
    showSnackbar(
      context: context,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: CText(
            'text_copied'.i18n,
            style: tsBody1Color(white),
            textAlign: TextAlign.start,
          )),
        ],
      ),
    );
    Clipboard.setData(ClipboardData(text: message.text));
  }

  void deleteForMe(BuildContext context, MessagingModel model) {
    showConfirmationDialog(
      context: context,
      key: const ValueKey('deleteForMeDialog'),
      iconPath: ImagePaths.delete,
      title: 'delete_for_me'.i18n,
      explanation: 'delete_for_me_explanation'.i18n,
      agreeText: 'delete'.i18n,
      agreeAction: () async {
        await model.deleteLocally(message);
        Navigator.pop(context);
      },
    );
  }

  void deleteForEveryone(BuildContext context, MessagingModel model) {
    showConfirmationDialog(
      context: context,
      key: const ValueKey('deleteForEveryoneDialog'),
      iconPath: ImagePaths.delete,
      title: 'delete_for_everyone'.i18n,
      explanation: 'delete_for_everyone_explanation'.i18n,
      agreeText: 'delete'.i18n,
      agreeAction: () async {
        await model.deleteGlobally(message);
        Navigator.pop(context);
      },
    );
  }

  double maxBubbleWidth(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.8;

  Map<String, int> countReactions() {
    final result = <String, int>{};
    message.reactions.values.forEach((reaction) {
      result[reaction.emoticon] = (result[reaction.emoticon] ?? 0) + 1;
    });
    return result;
  }
}
