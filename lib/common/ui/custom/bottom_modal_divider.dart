import 'package:lantern/common/common.dart';

class CBottomModalDivider extends StatelessWidget {
  const CBottomModalDivider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CDivider(
        size: 1,
        thickness: 1,
        margin: 0,
        color: Color.fromRGBO(235, 235, 235, 1));
  }
}
