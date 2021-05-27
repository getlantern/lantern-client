import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/message_types/reply_content_row.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

import 'message_utils.dart';

class StagingContainerItem extends StatelessWidget {
  const StagingContainerItem({
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
    // use the message's replyToId to identify who this is in response to
    final inResponseTo = matchIdToDisplayName(quotedMessage!.senderId, contact);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (quotedMessage != '')
                Expanded(
                  child: Text(
                    'Replying to $inResponseTo', //TODO: Add i18n
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              GestureDetector(
                onTap: () => onCloseListener(),
                child: const Icon(Icons.close, size: 20),
              )
            ],
          ),
          const SizedBox(height: 4),
          Row(children: [
            Expanded(
                child: Text(quotedMessage!.text.toString(),
                    style: const TextStyle(color: Colors.black54))),
            if (quotedMessage!.attachments.isNotEmpty)
              ReplyContentRow(
                  quotedMessage: quotedMessage as StoredMessage,
                  outbound: quotedMessage!.direction == MessageDirection.OUT,
                  model: model),
          ])
        ],
      ),
    );
  }
}
