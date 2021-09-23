import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:lantern/messaging/conversation/attachments/attachment.dart';
import 'package:lantern/messaging/conversation/contact_connection_card.dart';
import 'package:lantern/messaging/conversation/deleted_bubble.dart';
import 'package:lantern/messaging/conversation/replies/reply_snippet.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:url_launcher/url_launcher.dart';

import 'date_marker_bubble.dart';
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
  late final String dateMarker;
  late final Color color;
  late final Color backgroundColor;

  late final MessagingModel model;

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
    dateMarker = determineDateSwitch(priorMessage, nextMessage);
    color = isOutbound ? outboundMsgColor : inboundMsgColor;
    backgroundColor = isOutbound ? outboundBgColor : inboundBgColor;
  }

  @override
  Widget build(BuildContext context) {
    model = context.watch<MessagingModel>();

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
            child: overlayReactions(context, bubble(context)),
          ),
        ),
      ],
    );
  }

  Widget bubble(BuildContext context) {
    if (wasDeleted) {
      final humanizedSenderName =
          message.remotelyDeletedBy.id == contact.contactId.id
              ? contact.displayName
              : 'me'.i18n;
      return DeletedBubble('$humanizedSenderName deleted this message'.i18n);
    }

    return FocusedMenuHolder(
      menuWidth: maxBubbleWidth(context),
      onPressed: () {},
      menu: messageMenu(context),
      child: Column(
        crossAxisAlignment:
            isOutbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (dateMarker.isNotEmpty)
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsetsDirectional.only(bottom: 10),
                child: DateMarker(dateMarker)),
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
    final attachments = message.attachments.values
        .map((attachment) => attachmentWidget(attachment, isInbound));

    final isAudio = message.attachments.values.any(
        (attachment) => audioMimes.contains(attachment.attachment.mimeType));
    final isContactConnectionCard = message.hasIntroduction();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          constraints: BoxConstraints(
              minWidth: 1, maxWidth: maxBubbleWidth(context), minHeight: 1),
          clipBehavior: Clip.hardEdge,
          padding: EdgeInsetsDirectional.only(
              top: message.replyToId.isNotEmpty ? 8 : 0,
              bottom: 8,
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
          child: isContactConnectionCard
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
                      if (message.text.isNotEmpty)
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: Container(
                              padding: const EdgeInsetsDirectional.only(
                                  start: 8, end: 8, top: 8, bottom: 4),
                              child: MarkdownBody(
                                data: '${message.text}',
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
                                            style: tsBody1),
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
                          ...attachments,
                          Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: isOutbound
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                StatusRow(isOutbound, isInbound, message),
                              ]),
                        ],
                      )
                    ]),
        );
      },
    );
  }

  SizedBox messageMenu(BuildContext context) {
    var textCopied = false;

    return SizedBox(
      height: 311,
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
              onTap: () => deleteForMe(context),
            ),
            if (isOutbound)
              CListTile(
                height: 48,
                showDivider: false,
                leading: ImagePaths.delete,
                content: 'delete_for_everyone'.i18n,
                onTap: () => deleteForEveryone(context),
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

  void deleteForMe(BuildContext context) {
    showAlertDialog(
      context: context,
      key: const ValueKey('deleteForMeDialog'),
      barrierDismissible: true,
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            CTextWrap('delete_for_me_explanation'.i18n, style: tsBody1)
          ],
        ),
      ),
      title: CText('delete_for_me'.i18n, style: tsSubtitle1),
      agreeAction: () => model.deleteLocally(message),
      agreeText: 'delete'.i18n,
    );
  }

  void deleteForEveryone(BuildContext context) {
    showAlertDialog(
      context: context,
      key: const ValueKey('deleteForEveryoneDialog'),
      barrierDismissible: true,
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            CTextWrap('delete_for_everyone_explanation'.i18n, style: tsBody1)
          ],
        ),
      ),
      title: CText('delete_for_everyone'.i18n, style: tsSubtitle1),
      agreeAction: () => model.deleteLocally(message),
      agreeText: 'delete'.i18n,
    );
  }

  String determineDateSwitch(
      StoredMessage? priorMessage, StoredMessage? nextMessage) {
    if (priorMessage == null || nextMessage == null) return '';

    var currentDateTime =
        DateTime.fromMillisecondsSinceEpoch(priorMessage.ts.toInt());
    var nextMessageDateTime =
        DateTime.fromMillisecondsSinceEpoch(nextMessage.ts.toInt());

    if (nextMessageDateTime.difference(currentDateTime).inDays >= 1) {
      currentDateTime = nextMessageDateTime;
      return DateFormat.yMMMMd('en_US').format(currentDateTime);
    }

    return '';
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
