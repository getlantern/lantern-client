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
  final BoxConstraints constraints;

  const MessageBarPreviewRecording(
      {required this.model,
      required this.audioController,
      required this.onCancelRecording,
      required this.constraints,
      required this.onSend});

  @override
  Widget build(BuildContext context) {
    audioController.barsLimit = constraints.maxWidth >= 415
        ? 75
        : constraints.maxWidth >= 400
            ? 60
            : constraints.maxWidth >= 350
                ? 50
                : 40;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: AudioWidget(
        inbound: true,
        gap: 0.5,
        controller: audioController,
        initialColor: Colors.black,
        progressColor: Colors.grey,
        backgroundColor: Colors.white,
        showTimeRemaining: false,
        widgetHeight: kBottomNavigationBarHeight * 0.6,
        widgetWidth: constraints.maxWidth * 0.6,
        waveHeight: kBottomNavigationBarHeight * 0.59,
        previewBarHeight: kBottomNavigationBarHeight * 0.6,
        padding: const EdgeInsets.only(bottom: 5),
        iconSize: kBottomNavigationBarHeight * 0.3,
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
    // return Container(
    //   width: 100.w,
    //   height: kBottomNavigationBarHeight,
    //   child: Flex(
    //     direction: Axis.horizontal,
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     mainAxisSize: MainAxisSize.max,
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     children: [
    //       Flexible(
    //         child: AudioWidget(
    //           inbound: true,
    //           gap: 0.6,
    //           controller: audioController,
    //           initialColor: Colors.black,
    //           progressColor: Colors.grey,
    //           backgroundColor: Colors.white,
    //           showTimeRemaining: false,
    //           widgetHeight: 40,
    //           widgetWidth: 52.w,
    //           waveHeight: 39,
    //           previewBarHeight: 39,
    //           padding: const EdgeInsets.only(bottom: 5),
    //         ),
    //       ),
    //       Flex(
    //         direction: Axis.horizontal,
    //         mainAxisSize: MainAxisSize.min,
    //         mainAxisAlignment: MainAxisAlignment.end,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: [
    //           IconButton(
    //             icon: const Icon(Icons.delete, color: Colors.black),
    //             onPressed: onCancelRecording,
    //           ),
    //           VerticalDivider(
    //             color: const Color.fromRGBO(235, 235, 235, 1),
    //             indent: 1.h,
    //             endIndent: 1.h,
    //           ),
    //           IconButton(
    //             icon: const Icon(Icons.send,
    //                 color: Color.fromRGBO(219, 10, 91, 1.0)),
    //             onPressed: onSend,
    //           ),
    //         ],
    //       ),
    //     ],
    //   ),
    // );
  }
}
