import 'package:lantern/package_store.dart';

//// A TextButton with our standard styling
class Button extends StatelessWidget {
  late final String text;
  late final String? iconPath;
  late final void Function()? onPressed;

  Button({required this.text, this.iconPath, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.only(top: 15, bottom: 15)),
          backgroundColor:
              MaterialStateProperty.all<Color>(HexColor(primaryPink))),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
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
  }
}
