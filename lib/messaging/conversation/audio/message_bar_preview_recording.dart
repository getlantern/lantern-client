import 'package:lantern/messaging/messaging.dart';

import 'audio_widget.dart';

class MessageBarPreviewRecording extends StatelessWidget {
  final MessagingModel model;
  final AudioController audioController;
  final VoidCallback onCancelRecording;
  final VoidCallback? onSend;

  const MessageBarPreviewRecording(
      {required this.model,
      required this.audioController,
      required this.onCancelRecording,
      required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 18),
            child: AudioWidget(
              controller: audioController,
              initialColor: Colors.black,
              progressColor: outboundMsgColor,
            ),
          ),
        ),
        IconButton(
          icon: const CAssetImage(path: ImagePaths.delete),
          onPressed: onCancelRecording,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 8, bottom: 8),
          child: VerticalDivider(thickness: 1, width: 1, color: grey3),
        ),
        IconButton(
          icon: mirrorLTR(
            context: context,
            child: CAssetImage(path: ImagePaths.send_rounded, color: pink4),
          ),
          onPressed: onSend,
        ),
      ],
    );
  }
}
