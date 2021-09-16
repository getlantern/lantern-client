import 'dart:ui';
import 'package:lantern/common/common.dart';

class CTextWrap extends StatelessWidget {
  final String text;
  final CTextStyle style;
  final TextAlign? textAlign;

  CTextWrap(this.text, {required this.style, this.textAlign}) : super();

  @override
  Widget build(BuildContext context) {
    return CText(text,
        style: style,
        textAlign: textAlign ?? TextAlign.start,
        overflow: TextOverflow.visible);
  }
}
