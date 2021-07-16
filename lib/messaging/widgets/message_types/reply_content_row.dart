import 'dart:ui';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/messaging/messaging_model.dart';

class ReplyContentRow extends StatelessWidget {
  const ReplyContentRow({
    Key? key,
    required this.quotedMessage,
    required this.outbound,
    required this.model,
  }) : super(key: key);

  final StoredMessage quotedMessage;
  final bool outbound;
  final MessagingModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (quotedMessage.attachments.isNotEmpty)
          Text(quotedMessage.attachments[0]!.attachment.mimeType.split('/')[0],
              style: const TextStyle(fontStyle: FontStyle.italic)),
        if (quotedMessage.attachments.isNotEmpty)
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FutureBuilder(
                      future: model.thumbnail(
                          quotedMessage.attachments[0] as StoredAttachment),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            if (snapshot.hasError) {
                              return const Icon(Icons.error_outlined);
                            }
                            return Image.memory(snapshot.data,
                                errorBuilder: (BuildContext context,
                                        Object error, StackTrace? stackTrace) =>
                                    const Icon(Icons.error_outlined),
                                filterQuality: FilterQuality.high,
                                scale: 10);
                          default:
                            return Transform.scale(
                                scale: 0.5,
                                child: const CircularProgressIndicator());
                        }
                      }),
                  if (quotedMessage.attachments[0]!.attachment.mimeType
                      .contains('video'))
                    const Icon(Icons.play_circle_outline,
                        color: Colors.white, size: 30)
                ],
              )),
      ],
    );
  }
}
