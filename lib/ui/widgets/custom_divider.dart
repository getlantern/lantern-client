import 'package:lantern/package_store.dart';

class CustomDivider extends StatelessWidget {
  late final String? label;
  late final double horizontalMargin;

  CustomDivider({Key? key, this.label, this.horizontalMargin = 20})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(
        margin: EdgeInsets.symmetric(
          horizontal: horizontalMargin,
          vertical: label != null ? 20 : 8,
        ),
        color: HexColor(borderColor),
        height: 1,
      ),
      if (label != null)
        Positioned(
          top: 13,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            color: Colors.white,
            child: Text(
              label!,
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
        ),
    ]);
  }
}
