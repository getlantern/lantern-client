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
            padding: const EdgeInsets.only(left: 18),
            child: AudioWidget(
              controller: audioController,
              initialColor: Colors.black,
              progressColor: outboundMsgColor,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.black),
          onPressed: onCancelRecording,
        ),
        IconButton(
          icon: Icon(Icons.send, color: pink4),
          onPressed: onSend,
        ),
      ],
    );
  }
}
