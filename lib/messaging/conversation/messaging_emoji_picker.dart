import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class MessagingEmojiPicker extends StatelessWidget {
  final double height;
  final String emptySuggestions;
  final Function(Category, Emoji) onEmojiSelected;
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
        return EmojiPicker(
          key: key,
          onBackspacePressed: onBackspacePressed,
          onEmojiSelected: onEmojiSelected,
          config: Config(
            initCategory: Category.SMILEYS,
            columns: constraints.maxWidth ~/ 40.0,
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
      }),
    );
  }
}
