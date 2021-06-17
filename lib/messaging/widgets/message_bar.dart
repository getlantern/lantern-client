import 'package:flutter/material.dart';
import 'package:lantern/package_store.dart';

class MessageBar extends StatelessWidget {
  final bool displayEmojis;
  final VoidCallback? onEmojiTap;
  final VoidCallback onTextFieldTap;
  final VoidCallback? onSend;
  final Function(String)? onTextFieldChanged;
  final Function(String)? onFieldSubmitted;
  final TextEditingController messageController;
  final FocusNode? focusNode;
  final bool sendIcon;
  final double width;
  final double height;
  const MessageBar(
      {this.onEmojiTap,
      this.focusNode,
      required this.onSend,
      required this.width,
      required this.height,
      required this.onTextFieldChanged,
      required this.messageController,
      required this.onFieldSubmitted,
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
        leading: IconButton(
          onPressed: onEmojiTap,
          icon: Icon(Icons.sentiment_very_satisfied,
              color: !displayEmojis
                  ? Theme.of(context).primaryIconTheme.color
                  : Theme.of(context).primaryColorDark),
        ),
        title: TextFormField(
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
        trailing: sendIcon
            ? IconButton(
                icon: const Icon(Icons.send, color: Colors.black),
                onPressed: onSend,
              )
            : Flex(
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () async =>
                        print('better change'), //await _selectFilesToShare(),
                    icon: const Icon(Icons.add_circle_rounded),
                  ),
                  IconButton(
                      onPressed: () => print('NICESOTOBAYO'),
                      // onPressed: () => _startRecording(),
                      icon: const Icon(Icons.mic))
                ],
              ),
      ),
    );
  }
}
