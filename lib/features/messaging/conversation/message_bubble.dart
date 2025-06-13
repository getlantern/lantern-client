import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lantern/features/messaging/conversation/attachments/attachment.dart';
import 'package:lantern/features/messaging/conversation/contact_connection_card.dart';
import 'package:lantern/features/messaging/messaging.dart';
import 'package:lantern/features/replica/logic/markdown_link_builder.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

import 'mime_type.dart';
import 'reactions.dart';
import 'reply.dart';
import 'status_row.dart';

class MessageBubble extends StatelessWidget {
  static const rounded = Radius.circular(16);
  static const squared = Radius.zero;

  final StoredMessage message;
  final void Function() onEmojiTap;
  final Contact contact;
  final void Function() onOpenMenu;
  final void Function() onReply;
  final void Function() onTapReply;

  late final bool isOutbound;
  late final bool isInbound;
  late final bool isStartOfBlock;
  late final bool isEndOfBlock;
  late final bool isNewestMessage;
  late final bool wasRemotelyDeleted;
  late final bool isAttachment;
  late final bool hasReactions;
  late final bool rendersAsText;
  late final Color color;
  late final Color backgroundColor;

  MessageBubble({
    Key? key,
    required this.message,
    StoredMessage? priorMessage,
    StoredMessage? nextMessage,
    required this.contact,
    required this.onOpenMenu,
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
    wasRemotelyDeleted = message.remotelyDeletedAt != 0;
    isAttachment = message.attachments.isNotEmpty;
    hasReactions = message.reactions.isNotEmpty;
    rendersAsText = message.text.isNotEmpty || wasRemotelyDeleted;
    color = isOutbound ? outboundMsgColor : inboundMsgColor;
    backgroundColor = isOutbound ? outboundBgColor : inboundBgColor;
  }

  @override
  Widget build(BuildContext context) {
    if (message.firstViewedAt == 0) {
      messagingModel.markViewed(message);
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
              bottom: isNewestMessage ? 8 : 0,
            ),
            child: overlayReactions(context, bubble(context, messagingModel)),
          ),
        ),
      ],
    );
  }

  // Renders bubble inside overlayReactions
  Widget bubble(BuildContext context, MessagingModel model) {
    return FocusedMenuHolder(
      menuWidth: maxBubbleWidth(context),
      onOpen: onOpenMenu,
      menu: messageMenu(context, model),
      builder: (menuOpen) => Column(
        crossAxisAlignment:
            isOutbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          content(context, model),
        ],
      ),
    );
  }

  // Renders the overlay which pins the reaction emojis to the exterior of the bubble, which it envelops.
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
    return Stack(
      alignment: isLTR(context)
          ? isOutbound
              ? Alignment.topLeft
              : Alignment.topRight
          : isOutbound
              ? Alignment.topRight
              : Alignment.topLeft,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            top: 12,
            start: isOutbound ? padding : 0,
            end: isInbound ? padding : 0,
          ),
          child: child,
        ),
        reactionsWidget,
      ],
    );
  }

  // Distinguishes between contact connection card, text message, audio message, attachments, replies.
  // Handles URLs on tap.
  // Adds status row.
  Widget content(BuildContext context, MessagingModel model) {
    assert(
      message.attachments.values.length <= 1,
      'display of messages with multiple attachments is unsupported',
    );

    final attachment = message.attachments.isEmpty
        ? null
        : attachmentWidget(
            contact,
            message,
            message.attachments.values.first,
            isInbound,
          );

    final isAudio = message.attachments.values.any(
      (attachment) => audioMimes.contains(attachment.attachment.mimeType),
    );
    final isContactConnectionCard = message.hasIntroduction();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return wrapBubble(
          context,
          isAudio,
          isContactConnectionCard
              ? ContactConnectionCard(contact, isInbound, isOutbound, message)
              : wrapIntrinsicWidthIfNecessary(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.replyToId.isNotEmpty)
                        model.singleMessage(
                            message.replyToSenderId, message.replyToId,
                            (context, replyToMessage, child) {
                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => onTapReply(),
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(
                                start: 8,
                                end: 8,
                                top: 8,
                                bottom: rendersAsText ? 0 : 8,
                              ),
                              child: SizedBox(
                                child: Reply(
                                  contact: contact,
                                  message: replyToMessage,
                                  isOutbound: isOutbound,
                                ),
                              ),
                            ),
                          );
                        }),
                      if (rendersAsText)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 8,
                            end: 8,
                            top: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: Container(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 8,
                                    end: 8,
                                    bottom: 4,
                                  ),
                                  child: MarkdownBody(
                                    data: wasRemotelyDeleted
                                        ? 'message_deleted'.i18n.fill(
                                            [contact.displayNameOrFallback],
                                          )
                                        : message.text,
                                    onTapLink: (
                                      String text,
                                      String? href,
                                      String title,
                                    ) async {
                                      if (href != null &&
                                          await canLaunch(href)) {
                                        CDialog(
                                          title: 'open_url'.i18n,
                                          description:
                                              'are_you_sure_you_want_to_open'
                                                  .i18n
                                                  .fill([href]),
                                          agreeText: 'continue'.i18n,
                                          agreeAction: () async {
                                            await launch(href);
                                            return true;
                                          },
                                        ).show(context);
                                      }
                                    },
                                    styleSheet: MarkdownStyleSheet(
                                      a: tsBody3.copiedWith(
                                        color: color,
                                        decoration: TextDecoration.underline,
                                      ),
                                      p: tsBody3.copiedWith(
                                        color: color,
                                        fontStyle: wasRemotelyDeleted
                                            ? FontStyle.italic
                                            : null,
                                      ),
                                    ),
                                    builders: {
                                      'replica':
                                          ReplicaLinkMarkdownElementBuilder(
                                        openLink: (replicaApi, replicaLink) {
                                          // TODO <10-11-21, soltzen> Determine MIME type first
                                          // context.pushRoute(
                                          //     FullscreenReplicaVideoViewer(
                                          //         replicaLink: replicaLink));
                                        },
                                      ),
                                    },
                                    inlineSyntaxes: <md.InlineSyntax>[
                                      ReplicaLinkSyntax()
                                    ],
                                    extensionSet:
                                        md.ExtensionSet.gitHubFlavored,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Stack(
                        alignment: isOutbound
                            ? AlignmentDirectional.bottomEnd
                            : AlignmentDirectional.bottomStart,
                        children: [
                          if (attachment != null) attachment,
                          FittedBox(
                            fit: BoxFit.contain,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: isOutbound
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 8,
                                    end: 8,
                                  ),
                                  child: StatusRow(isOutbound, message),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget wrapIntrinsicWidthIfNecessary(Widget child) {
    if (rendersAsText) {
      return IntrinsicWidth(child: child);
    }
    return child;
  }

  // Handles borders and their radii
  Widget wrapBubble(BuildContext context, bool isAudio, Widget child) {
    final borderRadius = isLTR(context)
        ? BorderRadius.only(
            topLeft: isInbound && !isStartOfBlock ? squared : rounded,
            topRight: isOutbound && !isStartOfBlock ? squared : rounded,
            bottomLeft: isInbound && (isNewestMessage || !isEndOfBlock)
                ? squared
                : rounded,
            bottomRight: isOutbound && (isNewestMessage || !isEndOfBlock)
                ? squared
                : rounded,
          )
        : BorderRadius.only(
            topLeft: isOutbound && !isStartOfBlock ? squared : rounded,
            topRight: isInbound && !isStartOfBlock ? squared : rounded,
            bottomLeft: isOutbound && (isNewestMessage || !isEndOfBlock)
                ? squared
                : rounded,
            bottomRight: isInbound && (isNewestMessage || !isEndOfBlock)
                ? squared
                : rounded,
          );

    if (wasRemotelyDeleted) {
      return DottedBorder(
        color: grey4,
        dashPattern: [3],
        strokeWidth: 1,
        customPath: (size) => borderRadius.toPath(size),
        child: ClipPath(
          clipper: borderRadius.toClipper(),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              top: message.replyToId.isNotEmpty ? 8 : 0,
            ),
            child: child,
          ),
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(
        minWidth: 1,
        maxWidth: maxBubbleWidth(context),
        minHeight: 1,
      ),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }

  // Renders message options (Reply, Copy, Delete) on long tap
  // Renders "Message disappears on/at ..." line.
  SizedBox messageMenu(BuildContext context, MessagingModel model) {
    var textCopied = false;
    var isConnectionCard = message.hasIntroduction();
    var height = isConnectionCard ? 171.0 : 219.0;
    if (isOutbound) height += 48;
    if (!isAttachment && !wasRemotelyDeleted) height += 48;
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 80,
              child: Reactions(
                message: message,
                onEmojiTap: onEmojiTap,
              ),
            ),
            const CDivider(),
            if (!isConnectionCard)
              ListItemFactory.focusMenuItem(
                icon: ImagePaths.reply,
                content: 'reply'.i18n,
                onTap: () {
                  Navigator.of(context).pop();
                  onReply();
                },
              ),
            if (!isAttachment && !wasRemotelyDeleted && !isConnectionCard)
              StatefulBuilder(
                key: ValueKey(message.id),
                builder: (context, setState) => ListItemFactory.focusMenuItem(
                  icon: textCopied
                      ? ImagePaths.check_green
                      : ImagePaths.content_copy,
                  content: 'copy_text'.i18n,
                  onTap: () {
                    copyText(context, message.text);
                    setState(() {
                      textCopied = true;
                    });
                    Future.delayed(
                      longAnimationDuration,
                      () => setState(() => textCopied = false),
                    );
                  },
                ),
              ),
            ListItemFactory.focusMenuItem(
              icon: ImagePaths.delete,
              content: 'delete_for_me'.i18n,
              onTap: () => deleteForMe(context, model),
            ),
            if (isOutbound)
              ListItemFactory.focusMenuItem(
                icon: ImagePaths.delete,
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
                        color: grey5,
                        lineHeight: tsBody2.fontSize,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void deleteForMe(BuildContext context, MessagingModel model) {
    CDialog(
      iconPath: ImagePaths.delete,
      title: 'delete_for_me'.i18n,
      description: 'delete_for_me_explanation'.i18n,
      agreeText: 'delete'.i18n,
      agreeAction: () async {
        await model.deleteLocally(message);
        Navigator.pop(context);
        return true;
      },
    ).show(context);
  }

  void deleteForEveryone(BuildContext context, MessagingModel model) {
    CDialog(
      iconPath: ImagePaths.delete,
      title: 'delete_for_everyone'.i18n,
      description: 'delete_for_everyone_explanation'.i18n,
      agreeText: 'delete'.i18n,
      agreeAction: () async {
        await model.deleteGlobally(message);
        Navigator.pop(context);
        return true;
      },
    ).show(context);
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
