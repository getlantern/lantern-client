import 'package:lantern/package_store.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 8,
        right: 24,
        left: 24,
      ),
      color: HexColor(borderColor),
      height: 1,
    );
  }
}
