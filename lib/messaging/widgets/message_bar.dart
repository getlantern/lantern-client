import 'package:flutter/material.dart';
import 'package:lantern/messaging/widgets/countdown_timer.dart';
import 'package:lantern/messaging/widgets/voice_recorder.dart';
import 'package:lantern/package_store.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class MessageBar extends StatelessWidget {
  final bool displayEmojis;
  final bool willCancelRecording;
  final VoidCallback? onEmojiTap;
  final VoidCallback onTextFieldTap;
  final VoidCallback? onSend;
  final VoidCallback? onFileSend;
  final VoidCallback onRecording;
  final VoidCallback onStopRecording;
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
  final VoidCallback onSwipeLeft;
  final Function onTapUpListener;

  MessageBar(
      {this.onEmojiTap,
      this.focusNode,
      required this.onSwipeLeft,
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
          : const EdgeInsets.only(right: 1.0, left: 1.0, bottom: 6.0),
      child: ListTile(
        contentPadding: isRecording
            ? const EdgeInsets.only(right: 0, left: 8.0, bottom: 0)
            : const EdgeInsets.only(right: 8.0, left: 8.0, bottom: 0),
        leading: isRecording
            ? Flex(
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Flexible(
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 12,
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: CountdownTimer(stopWatchTimer: stopWatchTimer),
                    ),
                  ),
                ],
              )
            : IconButton(
                onPressed: onEmojiTap,
                icon: Icon(Icons.sentiment_very_satisfied,
                    color: !displayEmojis
                        ? Theme.of(context).primaryIconTheme.color
                        : Theme.of(context).primaryColorDark),
              ),
        title: isRecording
            ? const SizedBox()
            : TextFormField(
                autofocus: false,
                textInputAction: TextInputAction.send,
                controller: messageController,
                onTap: onTextFieldTap,
                onChanged: onTextFieldChanged,
                focusNode: focusNode,
                onFieldSubmitted: onFieldSubmitted,
                decoration: InputDecoration(
                  // Send icon
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'Message'.i18n,
                  border: const OutlineInputBorder(),
                ),
              ),
        trailing: sendIcon && !isRecording
            ? IconButton(
                icon: const Icon(Icons.send, color: Colors.black),
                onPressed: onSend,
              )
            : Flex(
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  isRecording
                      ? const SizedBox()
                      : IconButton(
                          onPressed: onFileSend,
                          icon: const Icon(Icons.add_circle_rounded),
                        ),
                  VoiceRecorder(
                    willCancelRecording: willCancelRecording,
                    onSwipeLeft: onSwipeLeft,
                    isRecording: isRecording,
                    onStopRecording: onStopRecording,
                    onTapUpListener: onTapUpListener,
                    onRecording: onRecording,
                  ),
                ],
              ),
      ),
    );
  }
}
