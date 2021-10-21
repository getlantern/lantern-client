import 'package:lantern/common/common.dart';

void showBottomModal({
  required BuildContext context,
  required List<Widget> children,
  bool isDismissible = true,
  Widget? title,
  CText? subtitle,
}) {
  showModalBottomSheet(
      context: context,
      isDismissible: isDismissible,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (context) => Wrap(alignment: WrapAlignment.center, children: [
            if (title != null)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: title),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 24.0, end: 24.0, bottom: 16.0),
                      child: subtitle,
                    ),
                  const CDivider(),
                ],
              ),
            ...children
          ]));
}
