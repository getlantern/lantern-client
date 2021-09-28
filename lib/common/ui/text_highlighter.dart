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
    return RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: text.split('**')[0],
          style: style,
          children: <TextSpan>[
            TextSpan(
                text: text.split('**')[1],
                style: style.copiedWith(
                    color: pink4, fontWeight: FontWeight.w500)),
            TextSpan(text: text.split('**')[2], style: style),
          ],
        ));
  }
}
