import 'package:lantern/common/common.dart';

class AppLoadingDialog {
  static void showLoadingDialog(BuildContext context) {
    context.loaderOverlay.show();
  }

  static void dismissLoadingDialog(BuildContext context) {
    context.loaderOverlay.hide();
  }
}
