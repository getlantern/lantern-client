import 'package:flutter/material.dart';
import 'package:lantern/messaging/widgets/message_types/status_row.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';

class ContentTrailing extends StatelessWidget {
  final bool outbound;
  final bool inbound;
  final bool showOnlyStatus;
  final Iterable<Widget> attachments;
  final StoredMessage msg;
  final PathAndValue<StoredMessage> message;
  final List<dynamic> reactionsList;

  const ContentTrailing(
      {Key? key,
      this.showOnlyStatus = false,
      required this.outbound,
      required this.inbound,
      required this.attachments,
      required this.msg,
      required this.message,
      required this.reactionsList})
      : super(key: key);

  @override
  Widget build(BuildContext context) => showOnlyStatus
      ? Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              outbound ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            StatusRow(outbound, inbound, msg, message, reactionsList),
          ],
        )
      : Stack(
          fit: StackFit.passthrough,
          alignment: outbound
              ? AlignmentDirectional.bottomEnd
              : AlignmentDirectional.bottomStart,
          children: [
            ...attachments,
            Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment:
                    outbound ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  StatusRow(outbound, inbound, msg, message, reactionsList)
                ]),
          ],
        );
}
