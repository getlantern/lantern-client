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
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FittedBox(
              child: AudioWidget(
                controller: audioController,
                initialColor: Colors.black,
                progressColor: Colors.grey,
                backgroundColor: Colors.white,
                showTimeRemaining: false,
                widgetHeight: 50,
                widgetWidth: MediaQuery.of(context).size.width,
                waveHeight: 50,
                previewBarHeight: 40,
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
          const VerticalDivider(
            color: Color.fromRGBO(235, 235, 235, 1),
            width: 10,
            thickness: 1,
          ),
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
