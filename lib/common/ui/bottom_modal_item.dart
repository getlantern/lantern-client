import 'package:lantern/messaging/messaging.dart';

/*
* Generic widget that renders a row with a Bottom modal option. 
*/
class BottomModalItem extends StatelessWidget {
  BottomModalItem({
    Key? key,
    required this.leading,
    required this.label,
    this.trailing,
    this.onTap,
  }) : super();

  final Widget leading;
  final String label;
  final Widget? trailing;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) => Wrap(children: [
        ListTile(
          leading: leading,
          title: TextOneLine(label, style: tsBody3),
          trailing: trailing,
          onTap: onTap,
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsetsDirectional.only(
              top: 5, bottom: 5, start: 16, end: 16),
        ),
        const CDivider(
            size: 1,
            thickness: 1,
            margin: 0,
            color: Color.fromRGBO(235, 235, 235, 1)),
      ]);
}
