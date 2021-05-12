import 'package:lantern/package_store.dart';

//// A TextButton with our standard styling
class Button extends StatelessWidget {
  late final String text;
  late final String? iconPath;
  late final void Function()? onPressed;
  late final double? width;
  late final bool inverted;

  Button(
      {required this.text,
      this.iconPath,
      this.onPressed,
      this.width,
      this.inverted = false});

  @override
  Widget build(BuildContext context) {
    var button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: HexColor(inverted ? white : primaryPink),
        padding: const EdgeInsets.symmetric(vertical: 15),
        side: BorderSide(width: 2, color: HexColor(primaryPink)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text.toUpperCase(),
              style: TextStyle(
                  color: HexColor(inverted ? primaryPink : white),
                  fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 5),
            if (iconPath != null)
              CustomAssetImage(
                path: iconPath!,
                color: Colors.white,
              )
          ],
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: button);
    } else {
      return button;
    }
  }
}
