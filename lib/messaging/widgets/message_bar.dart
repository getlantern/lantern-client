import 'package:flutter/material.dart';
import 'package:lantern/messaging/widgets/countdown_timer.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/custom_pan_gesture_recognizer.dart';
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
      child: ListTile(
        contentPadding:
            const EdgeInsets.only(right: 8.0, left: 8.0, bottom: 6.0),
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
            ? Center(
                child: Text(
                  willCancelRecording
                      ? 'will cancel'.i18n
                      : '< ' + 'swipe to cancel'.i18n,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )
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
                  //TODO: MOVE EVERYTHING FROM THE STACK INTO VOICE_RECORDER
                  Stack(
                    clipBehavior: Clip.none,
                    fit: StackFit.passthrough,
                    children: [
                      isRecording
                          ? Transform.scale(
                              scale: 2,
                              alignment: Alignment.bottomRight,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(38)),
                                ),
                                child: const SizedBox(
                                  height: 40,
                                  width: 40,
                                ),
                              ),
                            )
                          : const SizedBox(),
                      ForcedPanDetector(
                        onPanDown: _onPanDown,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        onDoubleTap: () {},
                        onTap: () {},
                        child: Icon(
                          Icons.mic,
                          size: isRecording ? 30.0 : 25,
                          color: isRecording ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  void _onPanUpdate(Offset details) => _handlePan(details, false);

  void _onPanEnd(Offset details) => _handlePan(details, true);

  void _handlePan(Offset details, bool isPanEnd) {
    if (isPanEnd && details.dx <= 200.0) {
      onSwipeLeft();
    }
    if (isPanEnd && details.dx > 200.0) {
      onStopRecording();
    }
  }

  bool _onPanDown(Offset details) {
    onRecording();
    _handlePan(details, false);
    return true;
  }
}
