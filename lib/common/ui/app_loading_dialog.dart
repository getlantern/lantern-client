import 'package:lantern/common/common.dart';

class AppLoadingDialog {
  static void showLoadingDialog(BuildContext context) {
    context.loaderOverlay.show(widget: spinner);
  }

  static void dismissLoadingDialog(BuildContext context) {
    context.loaderOverlay.hide();
  }
}
