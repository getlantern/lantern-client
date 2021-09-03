import 'package:flutter/material.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/package_store.dart';
import 'package:sizer/sizer.dart';

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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: FittedBox(
        child: AudioWidget(
          controller: audioController,
          initialColor: Colors.black,
          progressColor: outboundMsgColor,
          showTimeRemaining: false,
          height: kBottomNavigationBarHeight * 0.7,
          widgetWidth: MediaQuery.of(context).size.width * 0.6,
        ),
      ),
      trailing: Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: onCancelRecording,
          ),
          VerticalDivider(
            width: 4,
            color: const Color.fromRGBO(235, 235, 235, 1),
            indent: 1.h,
            endIndent: 1.h,
          ),
          IconButton(
            icon:
                const Icon(Icons.send, color: Color.fromRGBO(219, 10, 91, 1.0)),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
