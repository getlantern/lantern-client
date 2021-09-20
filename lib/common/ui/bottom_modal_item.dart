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
        SizedBox(
          height: 72,
          child: InkWell(
            onTap: onTap ?? () {},
            child: Ink(
              padding: const EdgeInsetsDirectional.only(start: 16.0, end: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 16.0),
                    child: leading,
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    child: Container(
                      child: Row(
                        children: [
                          Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(bottom: 1),
                              child: TextOneLine(
                                label,
                                style: tsSubtitle1Short,
                              ),
                            ),
                          ),
                          if (trailing != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: trailing!,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ),
        const CDivider(
            size: 1,
            thickness: 1,
            margin: 0,
            color: Color.fromRGBO(235, 235, 235, 1)),
      ]);
}
