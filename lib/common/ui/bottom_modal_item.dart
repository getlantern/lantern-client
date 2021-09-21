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
        CListTile(
            leading: Padding(
              padding: const EdgeInsetsDirectional.only(start: 16.0, end: 16.0),
              child: leading,
            ),
            content: Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 1),
                    child: CText(
                      label,
                      maxLines: 1,
                      style: tsSubtitle1Short,
                    ),
                  ),
                ),
              ],
            ),
            trailing: trailing ?? const SizedBox(),
            onTap: onTap),
        CDivider(height: 1, thickness: 1, margin: 0, color: grey3),
      ]);
}
