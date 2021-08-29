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
      width: 100.w,
      height: kBottomNavigationBarHeight,
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: AudioWidget(
              inbound: true,
              gap: 0.6,
              controller: audioController,
              initialColor: Colors.black,
              progressColor: Colors.grey,
              backgroundColor: Colors.white,
              showTimeRemaining: false,
              widgetHeight: 40,
              widgetWidth: 65.w,
              waveHeight: 40,
              previewBarHeight: 40,
            ),
          ),
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: onCancelRecording,
                child: Icon(
                  Icons.delete,
                  color: Colors.black,
                  size: 20.sp,
                ),
              ),
              VerticalDivider(
                color: const Color.fromRGBO(235, 235, 235, 1),
                indent: 1.h,
                endIndent: 1.h,
              ),
              GestureDetector(
                onTap: onSend,
                child: Icon(
                  Icons.send,
                  color: const Color.fromRGBO(219, 10, 91, 1.0),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 2.w),
            ],
          ),
        ],
      ),
    );
  }
}
