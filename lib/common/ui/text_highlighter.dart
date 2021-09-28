import 'package:lantern/common/common.dart';

class TextHighlighter extends StatelessWidget {
  const TextHighlighter({
    Key? key,
    required this.text,
    required this.style,
  }) : super(key: key);

  final String text;
  final CTextStyle style;

  @override
  Widget build(BuildContext context) {
    final fragments = text.split('**');
    return RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: fragments[0],
          style: style,
          children: <TextSpan>[
            TextSpan(
                text: fragments[1],
                style: style.copiedWith(
                    color: pink4, fontWeight: FontWeight.w500)),
            TextSpan(text: fragments[2], style: style),
          ],
        ));
  }
}
