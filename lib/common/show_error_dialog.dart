import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lantern/package_store.dart';

/// logs the given exception+stacktrace and shows a standard error dialog.
void showErrorDialog(
  BuildContext context, {
  required Object e,
  required StackTrace s,
  required String des,
}) {
  print('$e\n$s');
  showInfoDialog(context,
      title: 'Error'.i18n,
      des: des,
      icon: ImagePaths.alert_icon,
      buttonText: 'OK'.i18n);
}
