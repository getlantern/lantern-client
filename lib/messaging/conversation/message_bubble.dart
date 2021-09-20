import 'package:lantern/messaging/conversation/conversation.dart';
import 'package:lantern/messaging/conversation/deleted_bubble.dart';
import 'package:lantern/messaging/conversation/reactions.dart';
import 'package:lantern/messaging/conversation/reactions_utils.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:lantern/common/common.dart';
import 'package:intl/intl.dart';

import 'message_bubble_content.dart';
import 'date_marker_bubble.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.message,
    required this.priorMessage,
    required this.nextMessage,
    required this.contact,
    required this.onReply,
    required this.onTapReply,
    required this.onEmojiTap,
  }) : super(key: key);

  final PathAndValue<StoredMessage> message;
  final ShowEmojis onEmojiTap;
  final StoredMessage? priorMessage;
  final StoredMessage? nextMessage;
  final Contact contact;
  final Function(StoredMessage?) onReply;
  final Function(PathAndValue<StoredMessage>) onTapReply;

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return model.message(context, message,
        (BuildContext context, StoredMessage msg, Widget? child) {
      if (msg.firstViewedAt == 0) {
        model.markViewed(message);
      }
      final outbound = msg.direction == MessageDirection.OUT;
      final inbound = !outbound;
      final startOfBlock = priorMessage == null ||
          priorMessage?.direction != message.value.direction;
      final endOfBlock = nextMessage == null ||
          nextMessage!.direction != message.value.direction;
      final newestMessage = nextMessage == null;

      // constructs a Map<emoticon, List<reactorName>> : ['😢', ['DisplayName1', 'DisplayName2']]
      final reactions = constructReactionsMap(msg, contact);
      final isDateMarker = _determineDateSwitch(priorMessage, nextMessage);
      final wasDeleted = msg.remotelyDeletedAt != 0;
      final isAttachment = msg.attachments.isNotEmpty;

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            outbound ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Padding(
                padding: EdgeInsetsDirectional.only(
                    start: isDateMarker != ''
                        ? outbound
                            ? 20
                            : 4
                        : 4,
                    end: isDateMarker != ''
                        ? outbound
                            ? 4
                            : 20
                        : 4,
                    top: 4,
                    bottom: 4),
                child: _buildBubbleUI(
                  outbound,
                  inbound,
                  startOfBlock,
                  endOfBlock,
                  isDateMarker,
                  wasDeleted,
                  isAttachment,
                  newestMessage,
                  reactions,
                  msg,
                  message,
                  onTapReply,
                  context,
                  model,
                )),
          ),
        ],
      );
    });
  }

  Widget _buildBubbleUI(
    bool outbound,
    bool inbound,
    bool startOfBlock,
    bool endOfBlock,
    String? isDateMarker,
    bool wasDeleted,
    bool isAttachment,
    bool newestMessage,
    Map<String, List<dynamic>> reactions,
    StoredMessage msg,
    PathAndValue<StoredMessage> message,
    Function(PathAndValue<StoredMessage>) onTapReply,
    BuildContext context,
    MessagingModel model,
  ) {
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
              onReply(msg);
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
          if (outbound)
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
                                'This will delete the message for everyone.'
                                    .i18n,
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
              outbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (isDateMarker!.isNotEmpty)
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsetsDirectional.only(bottom: 10),
                  child: DateMarker(isDateMarker)),
            MessageBubbleContent(
                outbound,
                inbound,
                msg,
                message,
                contact,
                onTapReply,
                startOfBlock,
                endOfBlock,
                newestMessage,
                reactions,
                isAttachment),
          ],
        ));
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
}
