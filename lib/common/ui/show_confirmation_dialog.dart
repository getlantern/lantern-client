import 'package:lantern/common/common.dart';

void Function() showConfirmationDialog({
  required BuildContext context,
  Key? key,
  String? iconPath,
  required String title,
  required String explanation,
  required String agreeText,
  String dismissText = 'Cancel',
  required void Function() agreeAction,
  void Function()? dismissAction,
  bool barrierDismissible = true,
  Duration? autoDismissAfter,
}) {
  Timer? autoDismissTimer;
  var closed = false;

  void close() {
    autoDismissTimer?.cancel();
    if (!closed) {
      Navigator.pop(context);
      closed = true;
    }
  }

  if (autoDismissAfter != null) {
    autoDismissTimer = Timer(autoDismissAfter, () {
      dismissAction?.call();
    });
  }

  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return AlertDialog(
        key: key,
        title: Column(
          children: [
            if (iconPath != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 16),
                child: CAssetImage(path: iconPath, size: 24),
              ),
            CText(title, style: tsSubtitle1),
          ],
        ),
        content: SingleChildScrollView(
          child: CText(explanation, style: tsBody1),
        ),
        actions: [
          // DISMISS
          TextButton(
            onPressed: () {
              if (dismissAction != null) dismissAction();
              close();
            },
            child: CText(
              dismissText.i18n.toUpperCase(),
              style: tsButtonGrey,
            ),
          ),
          // AGREE
          TextButton(
            onPressed: () {
              agreeAction();
              close();
            },
            child: CText(
              agreeText.i18n.toUpperCase(),
              style: tsButtonPink,
            ),
          ),
        ],
      );
    },
  );

  return close;
}
