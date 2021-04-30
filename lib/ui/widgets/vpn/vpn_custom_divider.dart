import 'package:lantern/package_store.dart';

class VPNCustomDivider extends StatelessWidget {
  final double marginTop;
  final double marginBottom;

  const VPNCustomDivider(
      {Key? key, this.marginTop = 16, this.marginBottom = 16})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: marginTop, bottom: marginBottom),
      height: 1,
      width: double.infinity,
      color: HexColor(borderColor),
    );
  }
}
