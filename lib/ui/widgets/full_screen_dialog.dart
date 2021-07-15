import 'package:lantern/config/transitions.dart';
import 'package:lantern/package_store.dart';

/// Shows the supplied widget as a full screen dialog
void showFullScreenDialog(BuildContext context, Widget widget) {
  showGeneralDialog(
    context: context,
    transitionBuilder: defaultTransition,
    transitionDuration: defaultTransitionDuration,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return SizedBox.expand(
        child: Material(
          child: widget,
        ),
      );
    },
  );
}
