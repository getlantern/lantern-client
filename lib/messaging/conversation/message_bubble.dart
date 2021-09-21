import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/conversation/attachments/attachment.dart';
import 'package:lantern/messaging/conversation/contact_connection_card.dart';
import 'package:lantern/messaging/conversation/conversation.dart';
import 'package:lantern/messaging/conversation/deleted_bubble.dart';
import 'package:lantern/messaging/conversation/reactions.dart';
import 'package:lantern/messaging/conversation/reactions_utils.dart';
import 'package:lantern/messaging/conversation/replies/reply_snippet.dart';
import 'package:lantern/messaging/conversation/status_row.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:url_launcher/url_launcher.dart';

import 'date_marker_bubble.dart';
import 'mime_types.dart';
import 'reactions_utils.dart';

class MessageBubble extends StatelessWidget {
  static final rounded = const Radius.circular(8);
  static final squared = Radius.zero;

  final PathAndValue<StoredMessage> message;
  final ShowEmojis onEmojiTap;
  final Contact contact;
  final void Function() onReply;
  final void Function() onTapReply;

  late final StoredMessage msg;
  late final bool isOutbound;
  late final bool isInbound;
  late final bool isStartOfBlock;
  late final bool isEndOfBlock;
  late final bool isNewestMessage;
  late final bool wasDeleted;
  late final bool isAttachment;
  late final bool hasReactions;
  late final String dateMarker;
  late final MessagingModel model;
  late final Map<String, List<dynamic>> reactions;

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
    msg = message.value;
    isOutbound = msg.direction == MessageDirection.OUT;
    isInbound = !isOutbound;
    isStartOfBlock = priorMessage == null ||
        priorMessage.direction != message.value.direction;
    isEndOfBlock =
        nextMessage == null || nextMessage.direction != message.value.direction;
    isNewestMessage = nextMessage == null;
    wasDeleted = msg.remotelyDeletedAt != 0;
    isAttachment = msg.attachments.isNotEmpty;
    hasReactions = msg.reactions.isNotEmpty;
    dateMarker = _determineDateSwitch(priorMessage, nextMessage);
    reactions = constructReactionsMap();
  }

  @override
  Widget build(BuildContext context) {
    model = context.watch<MessagingModel>();

    if (msg.firstViewedAt == 0) {
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
                start: dateMarker != ''
                    ? isOutbound
                        ? 20
                        : 4
                    : 4,
                end: dateMarker != ''
                    ? isOutbound
                        ? 4
                        : 20
                    : 4,
                top: isStartOfBlock || hasReactions ? 8 : 2,
                bottom: isNewestMessage ? 4 : 0),
            child: overlayReactions(context, bubble(context)),
          ),
        ),
      ],
    );
  }

  Widget bubble(BuildContext context) {
    if (wasDeleted) {
      final humanizedSenderName =
          msg.remotelyDeletedBy.id == contact.contactId.id
              ? contact.displayName
              : 'me'.i18n;
      return DeletedBubble('$humanizedSenderName deleted this message'.i18n);
    }

    return FocusedMenuHolder(
      menuItems: [
        FocusedMenuItem(
          title: Flexible(
            fit: FlexFit.tight,
            child: Reactions(
              onEmojiTap: onEmojiTap,
              reactionOptions: reactions.keys.toList(),
              message: message,
              messagingModel: model,
            ),
          ),
          onPressed: () {},
        ),
        FocusedMenuItem(
          trailingIcon: const Icon(Icons.reply),
          title: CText('reply'.i18n, style: tsBody1),
          onPressed: () {
            onReply();
          },
        ),
        if (!isAttachment)
          FocusedMenuItem(
            trailingIcon: const Icon(Icons.copy),
            title: CText('copy_text'.i18n, style: tsBody1),
            onPressed: () {
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
              Clipboard.setData(ClipboardData(text: message.value.text));
            },
          ),
        FocusedMenuItem(
            trailingIcon: const Icon(Icons.delete),
            title: CText('delete_for_me'.i18n, style: tsBody1),
            onPressed: () => showAlertDialog(
                  context: context,
                  key: const ValueKey('deleteDialog'),
                  barrierDismissible: true,
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        CTextWrap(
                            'This will delete the message for you only. Everyone else will still be able to see it.'
                                .i18n,
                            style: tsBody1)
                      ],
                    ),
                  ),
                  title: CText('Delete for me', style: tsBody3),
                  agreeAction: () => model.deleteLocally(message),
                  agreeText: 'Delete',
                )),
        if (isOutbound)
          FocusedMenuItem(
              trailingIcon: const Icon(Icons.delete_forever),
              title: CText('delete_for_everyone'.i18n, style: tsBody1),
              onPressed: () => showAlertDialog(
                    context: context,
                    key: const ValueKey('deleteDialog'),
                    barrierDismissible: true,
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          CTextWrap(
                              'This will delete the message for everyone.'.i18n,
                              style: tsBody1)
                        ],
                      ),
                    ),
                    title: CText('Delete for everyone', style: tsBody3),
                    agreeAction: () => model.deleteGlobally(message),
                    agreeText: 'Delete',
                  )),
      ],
      blurBackgroundColor: Colors.blueGrey[900],
      menuOffset: 5.0,
      bottomOffsetHeight: 50.0,
      menuItemExtent: 60,
      openWithTap: false,
      duration: const Duration(seconds: 0),
      animateMenuItems: false,
      onPressed: () {},
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

    final reactionsList = constructReactionsList(context, reactions, msg);
    final reactionsWidget = SizedBox(
      width: 50,
      height: 20,
      child: Container(
        decoration: BoxDecoration(color: pink4),
        child: Text("hello"),
      ),
    );

    return Stack(
      alignment: isOutbound ? Alignment.topLeft : Alignment.topRight,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
              top: 12, start: isOutbound ? 22 : 0, end: isInbound ? 22 : 0),
          child: child,
        ),
        reactionsWidget,
      ],
    );
  }

  Widget content(BuildContext context) {
    final attachments = msg.attachments.values
        .map((attachment) => attachmentWidget(attachment, isInbound));

    final isAudio = msg.attachments.values.any(
        (attachment) => audioMimes.contains(attachment.attachment.mimeType));
    final isContactConnectionCard = msg.hasIntroduction();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          constraints: BoxConstraints(
              minWidth: 1,
              maxWidth: MediaQuery.of(context).size.width * 0.8,
              minHeight: 1),
          clipBehavior: Clip.hardEdge,
          padding: EdgeInsets.only(
              top: msg.replyToId.isNotEmpty ? 8 : 0,
              bottom: 8,
              left: isAttachment ? 0 : 8,
              right: isAttachment ? 0 : 8),
          decoration: BoxDecoration(
            color: isOutbound ? outboundBgColor : inboundBgColor,
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
              ? ContactConnectionCard(
                  contact, isInbound, isOutbound, msg, message)
              : Column(
                  crossAxisAlignment: isOutbound
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
                              onTap: () => onTapReply(),
                              child: ReplySnippet(isOutbound, msg, contact),
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
                                      color: isOutbound
                                          ? outboundMsgColor
                                          : inboundMsgColor,
                                      decoration: TextDecoration.underline),
                                  p: tsBody3.copiedWith(
                                      color: isOutbound
                                          ? outboundMsgColor
                                          : inboundMsgColor),
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
                                StatusRow(isOutbound, isInbound, msg, message)
                              ]),
                        ],
                      )
                    ]),
        );
      },
    );
  }

  String _determineDateSwitch(
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

  /// constructs a Map<emoticon, List<reactorName>> : ['😢', ['DisplayName1', 'DisplayName2']]
  Map<String, List<dynamic>> constructReactionsMap() {
    // hardcode the list of available emoticons in a way that is convenient to parse
    var reactions = {
      '👍': [],
      '👎': [],
      '😄': [],
      '❤': [],
      '😢': [],
      '•••': []
    };
    // https://api.dart.dev/stable/2.12.4/dart-core/Map/Map.fromIterables.html
    // create a Map from Iterable<String> and Iterable<Reaction>
    var reactor_emoticon_map = {};
    Map.fromIterables(msg.reactions.keys, msg.reactions.values)
        // reactorID <---> emoticon to reactor_emoticon_map
        .forEach((reactorId, reaction) =>
            reactor_emoticon_map[reactorId] = reaction.emoticon);

    // swap key-value pairs to create emoticon <--> List<reactorId>
    reactor_emoticon_map.forEach((reactorId, reaction) {
      reactions[reaction] = [...?reactions[reaction], reactorId];
    });

    // humanize reactorIdList
    reactions.forEach((reaction, reactorIdList) =>
        reactions[reaction] = humanizeReactorIdList(reactorIdList, contact));

    return reactions;
  }

  List<dynamic> humanizeReactorIdList(
      List<dynamic> reactorIdList, Contact contact) {
    var humanizedList = [];
    if (reactorIdList.isEmpty) return humanizedList;

    reactorIdList.forEach((reactorId) =>
        humanizedList.add(matchIdToDisplayName(reactorId, contact)));
    return humanizedList;
  }

  String matchIdToDisplayName(String contactIdToMatch, Contact contact) {
    return contactIdToMatch == contact.contactId.id
        ? contact.displayName
        : 'me'.i18n;
  }
}
