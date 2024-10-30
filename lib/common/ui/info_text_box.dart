import 'package:lantern/core/utils/common.dart';

class InfoTextBox extends StatelessWidget {
  final String text;
  final bool? invertColors;
  const InfoTextBox({
    required this.text,
    this.invertColors = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsetsDirectional.only(
          start: 8,
          end: 8,
          bottom: 4,
        ),
        decoration: BoxDecoration(color: invertColors! ? white : black),
        child: CText(
          text,
          style: tsOverline.copiedWith(color: invertColors! ? black : white),
        ),
      ),
    );
  }
}
