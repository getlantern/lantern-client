import 'dart:developer' as developer;

import 'package:lantern/common/common.dart';

/// logs the given exception+stacktrace and shows a standard error dialog.
void showErrorDialog(
  BuildContext context, {
  required String des,
  Object? e,
  StackTrace? s,
}) {
  if (e != null && s != null) {
    developer.log(des, error: e, stackTrace: s);
  }
  showInfoDialog(context,
      title: 'Error'.i18n,
      des: des,
      assetPath: ImagePaths.alert,
      buttonText: 'OK'.i18n);
}
