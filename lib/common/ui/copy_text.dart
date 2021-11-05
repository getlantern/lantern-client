import 'package:lantern/common/common.dart';

void copyText(BuildContext context, String text) {
  showSnackbar(
    context: context,
    content: 'copied'.i18n,
  );
  Clipboard.setData(ClipboardData(text: text));
}
