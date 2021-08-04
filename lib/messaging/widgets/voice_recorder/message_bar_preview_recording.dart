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
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.fill,
              child: AudioWidget(
                controller: audioController,
                initialColor: Colors.black,
                progressColor: outboundMsgColor,
                backgroundColor: inboundBgColor,
                showTimeRemaining: false,
                width: MediaQuery.of(context).size.width * 0.6,
                waveHeight: 45,
              ),
            ),
          ),
          GestureDetector(
            onTap: onCancelRecording,
            child: Icon(
              Icons.delete,
              color: Colors.black,
              size: 20.sp,
            ),
          ),
          const VerticalDivider(color: Colors.transparent),
          GestureDetector(
            onTap: onSend,
            child: Icon(
              Icons.send,
              color: Colors.black,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }
}
