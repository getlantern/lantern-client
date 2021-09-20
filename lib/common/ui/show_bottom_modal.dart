import 'package:lantern/common/common.dart';

void showBottomModal({
  required BuildContext context,
  required List<Widget> children,
  bool isDismissible = true,
  String? title = '',
  String? subtitle = '',
}) {
  showModalBottomSheet(
      context: context,
      isDismissible: isDismissible,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (context) => Wrap(alignment: WrapAlignment.center, children: [
            if (title!.isNotEmpty)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child:
                        Center(child: TextOneLine(title, style: tsSubtitle1)),
                  ),
                  if (subtitle!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 16.0, end: 16.0, bottom: 16.0),
                      child: CTextWrap(subtitle, style: tsBody1),
                    ),
                  const CBottomModalDivider(),
                ],
              ),
            ...children,
          ]));
}
