import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/common/ui/humanize.dart';

class ConversationSticker extends StatelessWidget {
  final Contact contact;
  final bool isPendingIntroduction;
  const ConversationSticker({
    Key? key,
    required this.contact,
    required this.isPendingIntroduction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      minLeadingWidth: 18,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child:
            !isPendingIntroduction ? _fullyAddedIcon() : _partiallyAddedIcon(),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child:
            !isPendingIntroduction ? _fullyAddedText() : _partiallyAddedText(),
      ),
    );
  }

  Text _partiallyAddedText() {
    return Text(
        'Waiting for ${contact.displayName}. They will receive your messages once they accept the introduction.'
            .i18n,
        style: txConversationSticker);
  }

  Icon _partiallyAddedIcon() {
    return const Icon(Icons.more_horiz_rounded, size: 18, color: Colors.black);
  }

  Text _fullyAddedText() {
    return contact.messagesDisappearAfterSeconds > 0
        ? Text(
            'Messages disappear after ${contact.messagesDisappearAfterSeconds.humanizeSeconds(longForm: true)}',
            style: txConversationSticker,
            overflow: TextOverflow.ellipsis)
        : Text('New messages do not disappear',
            style: txConversationSticker, overflow: TextOverflow.ellipsis);
  }

  Icon _fullyAddedIcon() {
    return contact.messagesDisappearAfterSeconds > 0
        ? const Icon(Icons.timer, size: 18, color: Colors.black)
        : const Icon(Icons.lock_clock, size: 18, color: Colors.black);
  }
}
