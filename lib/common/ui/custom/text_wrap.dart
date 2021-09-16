import 'dart:ui';
import 'package:lantern/common/common.dart';

class CTextWrap extends StatelessWidget {
  final String text;
  final CTextStyle style;

  CTextWrap(this.text, {required this.style}) : super();

  @override
  Widget build(BuildContext context) {
    return CText(text,
        style: style,
        textAlign: TextAlign.left,
        overflow: TextOverflow.visible);
  }
}
