import 'package:lantern/core/utils/common.dart';

void showBottomModal({
  required BuildContext context,
  required List<Widget> children,
  bool isDismissible = true,
  Widget? title,
  CText? subtitle,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: white,
    isDismissible: isDismissible,
    isScrollControlled: true,
    // this allows the sheet to grow up to full height if necessary
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15.0),
        topRight: Radius.circular(15.0),
      ),
    ),
    builder: (context) => Wrap(
      alignment: WrapAlignment.center,
      children: [
        if (title != null)
          Column(
            children: [
              Container(
                padding: const EdgeInsetsDirectional.all(16),
                child: Center(child: title),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 24.0,
                    end: 24.0,
                    bottom: 16.0,
                  ),
                  child: subtitle,
                ),
              const CDivider(),
            ],
          ),
        ...children
      ],
    ),
  );
}
