import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class MessagingEmojiPicker extends StatelessWidget {
  final bool showEmojis;
  final String emptySuggestions;
  final double height;
  final Function(Category, Emoji) onEmojiSelected;
  final VoidCallback? onBackspacePressed;

  const MessagingEmojiPicker({
    required this.showEmojis,
    required this.emptySuggestions,
    this.height = 200,
    this.onBackspacePressed,
    required this.onEmojiSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Offstage(
        offstage: !showEmojis,
        child: SizedBox(
          height: height,
          width: MediaQuery.of(context).size.width,
          child: _showEmojiKeyBoard(context: context),
        ),
      );

  Widget _showEmojiKeyBoard({required BuildContext context}) => EmojiPicker(
        key: key,
        onBackspacePressed: onBackspacePressed,
        onEmojiSelected: onEmojiSelected,
        config: Config(
          initCategory: Category.SMILEYS,
          columns: 10,
          emojiSizeMax: 16.0,
          iconColor: Theme.of(context).primaryIconTheme.color ?? Colors.grey,
          iconColorSelected:
              Theme.of(context).accentIconTheme.color ?? Colors.blue,
          noRecentsStyle: Theme.of(context).textTheme.bodyText1 ??
              const TextStyle(fontSize: 15, color: Colors.black26),
          progressIndicatorColor: Theme.of(context).indicatorColor,
          noRecentsText: emptySuggestions,
          bgColor: Theme.of(context).backgroundColor,
          indicatorColor: Theme.of(context).indicatorColor,
        ),
      );
}
