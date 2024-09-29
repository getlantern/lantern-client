import 'package:lantern/features/messaging/messaging.dart';

import 'mime_type.dart';

class StatusRow extends StatelessWidget {
  final bool outbound;
  late final bool inbound;
  final StoredMessage message;
  late final bool isImageAttachment;

  StatusRow(this.outbound, this.message) : super() {
    inbound = !outbound;
    isImageAttachment = message.attachments.isNotEmpty &&
        [MimeType.IMAGE, MimeType.VIDEO]
            .contains(mimeTypeOf(message.attachments[0]!.attachment.mimeType));
  }

  @override
  Widget build(BuildContext context) {
    final msgSelfDeletes = !message.disappearAt.isZero;
    final color =
        outbound || isImageAttachment ? outboundMsgColor : inboundMsgColor;
    return Opacity(
      opacity: 0.8,
      child: Container(
        padding: const EdgeInsetsDirectional.only(bottom: 4, start: 8, end: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsetsDirectional.only(end: 2.0),
              child: HumanizedDate.fromMillis(
                message.ts.toInt(),
                builder: (context, date) => CText(
                  date,
                  style: tsOverlineShort.copiedWith(color: color),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsetsDirectional.only(end: 2.0),
              child: inbound
                  ? null
                  : Padding(
                      padding: const EdgeInsetsDirectional.only(start: 4),
                      child: message.status ==
                              StoredMessage_DeliveryStatus.COMPLETELY_SENT
                          ? CAssetImage(
                              path: ImagePaths.done_all,
                              size: 10,
                              color: color,
                            )
                          : message.status ==
                                  StoredMessage_DeliveryStatus.SENDING
                              ? SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 0.5,
                                    color: color,
                                  ),
                                )
                              : message.status ==
                                          StoredMessage_DeliveryStatus
                                              .COMPLETELY_FAILED ||
                                      message.status ==
                                          StoredMessage_DeliveryStatus
                                              .PARTIALLY_FAILED
                                  ? CAssetImage(
                                      path: ImagePaths.error_outline,
                                      size: 10,
                                      color: color,
                                    )
                                  : null,
                    ),
            ),
            if (msgSelfDeletes)
              Container(
                padding: const EdgeInsetsDirectional.only(start: 4.0),
                child: CountdownStopwatch(
                  startMillis: message.firstViewedAt.toInt(),
                  endMillis: message.disappearAt.toInt(),
                  color: color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
