import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lantern/messaging/widgets/message_bar_preview_recording.dart';
import 'package:lantern/messaging/widgets/message_bar_recording.dart';
import 'package:lantern/package_store.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class MessageBar extends StatelessWidget {
  final bool displayEmojis;
  final bool willCancelRecording;
  final bool finishedRecording;
  final Uint8List? recording;
  final VoidCallback? onEmojiTap;
  final VoidCallback onTextFieldTap;
  final VoidCallback? onSend;
  final VoidCallback? onFileSend;
  final VoidCallback onRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onInmediateSend;
  final Function(String)? onTextFieldChanged;
  final Function(String)? onFieldSubmitted;
  final TextEditingController messageController;
  final StopWatchTimer stopWatchTimer;
  final bool hasPermission;
  final FocusNode? focusNode;
  final bool sendIcon;
  final bool isRecording;
  final double width;
  final double height;
  final VoidCallback? onCancelRecording;
  final Function onTapUpListener;

  MessageBar(
      {this.onEmojiTap,
      this.focusNode,
      required this.onInmediateSend,
      required this.recording,
      required this.finishedRecording,
      required this.onCancelRecording,
      required this.onTapUpListener,
      required this.willCancelRecording,
      required this.stopWatchTimer,
      required this.isRecording,
      required this.onSend,
      required this.width,
      required this.height,
      required this.hasPermission,
      required this.onRecording,
      required this.onStopRecording,
      required this.onTextFieldChanged,
      required this.messageController,
      required this.onFieldSubmitted,
      required this.onFileSend,
      required this.displayEmojis,
      required this.onTextFieldTap,
      this.sendIcon = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: isRecording
          ? const EdgeInsets.only(right: 0, left: 8.0, bottom: 0)
          : null,
      child: IndexedStack(
        index: finishedRecording ? 1 : 0,
        children: [
          MessageBarRecording(
            finishedRecording: finishedRecording,
            onTapUpListener: onTapUpListener,
            stopWatchTimer: stopWatchTimer,
            isRecording: isRecording,
            onSend: onSend,
            hasPermission: hasPermission,
            onRecording: onRecording,
            sendIcon: sendIcon,
            onStopRecording: onStopRecording,
            onTextFieldChanged: onTextFieldChanged,
            messageController: messageController,
            onFieldSubmitted: onFieldSubmitted,
            onFileSend: onFileSend,
            displayEmojis: displayEmojis,
            onTextFieldTap: onTextFieldTap,
            onInmediateSend: onInmediateSend,
          ),
          recording == null
              ? const SizedBox()
              : MessageBarPreviewRecording(
                  onCancelRecording: onCancelRecording!,
                  recording: recording,
                  onSend: onSend,
                ),
        ],
      ),
    );
  }
}
