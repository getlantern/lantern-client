import 'dart:async';

import 'package:lantern/package_store.dart';

void showAlertDialog({
  required BuildContext context,
  barrierDismissible = true,
  required Widget title,
  required Widget content,
  String icon = '',
  String dismissText = 'Cancel',
  Function? dismissAction,
  String agreeText = 'Accept',
  Function? agreeAction,
  Duration? autoDismissAfter,
}) {
  Timer? autoDismissTimer;
  if (autoDismissAfter != null) {
    autoDismissTimer = Timer(autoDismissAfter, () {
      Navigator.pop(context);
    });
  }

  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return AlertDialog(
        title: title,
        content: content,
        actions: <Widget>[
          // DISMISS
          TextButton(
            onPressed: () {
              if (dismissAction != null) dismissAction();
              autoDismissTimer?.cancel();
              Navigator.pop(context);
            },
            child: Text(
              dismissText.i18n.toUpperCase(),
              style: tsAlertDialogButtonGrey,
            ),
          ),
          // AGREE
          TextButton(
            onPressed: () {
              if (agreeAction != null) agreeAction();
              autoDismissTimer?.cancel();
              Navigator.pop(context);
            },
            child: Text(
              agreeText.i18n.toUpperCase(),
              style: tsAlertDialogButtonPink,
            ),
          ),
        ],
      );
    },
  );
}
