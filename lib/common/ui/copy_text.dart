import 'package:lantern/common/common.dart';

void copyText(BuildContext context, String text) {
  showSnackbar(
    context: context,
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: CText(
          'copied'.i18n,
          style: tsBody1Color(white),
          textAlign: TextAlign.start,
        )),
      ],
    ),
  );
  Clipboard.setData(ClipboardData(text: text));
}
