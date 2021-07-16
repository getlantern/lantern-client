import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:lantern/enums/mime_reply.dart';
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
      child: Flex(
        direction: Axis.vertical,
        children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: Text(
                  'Replying to $inResponseTo', //TODO: Add i18n
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: GestureDetector(
                  onTap: () => onCloseListener(),
                  child: const Icon(Icons.close, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              quotedMessage?.text != null && quotedMessage!.text.isNotEmpty
                  ? Flexible(
                      child: Text(
                        quotedMessage!.text.toString(),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    )
                  : const SizedBox(),
              MimeReply.reply(quotedMessage),
            ],
          ),
        ],
      ),
      // child: Column(
      //   children: [
      //     Row(
      //       children: [
      //         if (quotedMessage != null)
      //           Expanded(
      //             child: Text(
      //               'Replying to $inResponseTo', //TODO: Add i18n
      //               style: const TextStyle(fontWeight: FontWeight.bold),
      //             ),
      //           ),
      //         GestureDetector(
      //           onTap: () => onCloseListener(),
      //           child: const Icon(Icons.close, size: 20),
      //         )
      //       ],
      //     ),
      //     const SizedBox(height: 4),
      //     Row(children: [
      //       Expanded(
      //           child: Text(quotedMessage!.text.toString(),
      //               style: const TextStyle(color: Colors.black54))),
      //       if (quotedMessage!.attachments.isNotEmpty)
      //         ReplyContentRow(
      //             quotedMessage: quotedMessage as StoredMessage,
      //             outbound: quotedMessage!.direction == MessageDirection.OUT,
      //             model: model),
      //     ])
      //   ],
      // ),
    );
  }
}
