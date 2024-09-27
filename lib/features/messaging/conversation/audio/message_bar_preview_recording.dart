import 'package:lantern/features/messaging/messaging.dart';

import 'audio_widget.dart';

class MessageBarPreviewRecording extends StatelessWidget {
  final AudioController audioController;
  final VoidCallback onCancelRecording;
  final VoidCallback? onSend;

  const MessageBarPreviewRecording({
    required this.audioController,
    required this.onCancelRecording,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final children = [
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
    ];

    if (Directionality.of(context) == TextDirection.rtl) {
      // swap AudioWidget and delete button
      final audioWidget = children[0];
      final deleteButton = children[1];
      children[0] = deleteButton;
      children[1] = audioWidget;
    }
    return Container(
      height: messageBarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}
