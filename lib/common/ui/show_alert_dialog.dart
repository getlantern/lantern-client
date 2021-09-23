import 'dart:async';

import 'package:lantern/common/common.dart';

void showAlertDialog({
  required BuildContext context,
  Key? key,
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
        title: title,
        content: content,
        actions: <Widget>[
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
              if (agreeAction != null) agreeAction();
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
