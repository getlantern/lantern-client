import 'dart:developer' as developer;

import 'package:lantern/common/common.dart';

/// logs the given exception+stacktrace and shows a standard error dialog.
void showErrorDialog(
  BuildContext context, {
  required Object e,
  required StackTrace s,
  required String des,
}) {
  developer.log(des, error: e, stackTrace: s);
  showInfoDialog(
    context,
    title: 'Error'.i18n,
    des: des,
    assetPath: ImagePaths.alert,
    confirmButtonText: 'OK'.i18n,
    confirmButtonAction: () async => await context.router.pop(),
  );
}
