import 'package:lantern/core/utils/common.dart';

class ExplanationStep extends StatelessWidget {
  ExplanationStep(this.icon, this.text);

  String icon;
  String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsetsDirectional.only(end: 16),
          child: CAssetImage(
            path: icon,
            color: Colors.black,
          ),
        ),
        Flexible(
          child: CText(
            text,
            style: tsBody1,
          ),
        ),
      ],
    );
  }
}
