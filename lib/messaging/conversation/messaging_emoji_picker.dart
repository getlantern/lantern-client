import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as _EmojiPicker;
import 'package:flutter/material.dart';
import 'package:lantern/common/common.dart';

class MessagingEmojiPicker extends StatelessWidget {
  final double height;
  final String emptySuggestions;
  final Function(_EmojiPicker.Category, _EmojiPicker.Emoji) onEmojiSelected;
  final VoidCallback? onBackspacePressed;

  const MessagingEmojiPicker({
    required this.height,
    required this.emptySuggestions,
    this.onBackspacePressed,
    required this.onEmojiSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return _EmojiPicker.EmojiPicker(
          key: key,
          onBackspacePressed: onBackspacePressed,
          onEmojiSelected: onEmojiSelected,
          config: _EmojiPicker.Config(
            initCategory: _EmojiPicker.Category.SMILEYS,
            columns: constraints.maxWidth ~/ 40.0,
            iconColor: grey5,
            iconColorSelected: black,
            noRecentsStyle: TextStyle(fontSize: 15, color: black),
            progressIndicatorColor: black,
            noRecentsText: emptySuggestions,
            bgColor: white,
            indicatorColor: grey5,
          ),
        );
      }),
    );
  }
}
