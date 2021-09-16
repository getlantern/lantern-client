import 'package:lantern/common/common.dart';

class KeyboardState {
  var visible = false;
  var mostRecentHeight = 0.0;

  KeyboardState(this.mostRecentHeight) {
    visible = mostRecentHeight > 0;
  }
}

/// Utility for checking height and visibility of keyboard.
class KeyboardHelper extends ValueNotifier<KeyboardState> {
  static KeyboardHelper instance = KeyboardHelper();
  final _keyboardVisibilityController = KeyboardVisibilityController();

  KeyboardHelper() : super(KeyboardState(currentHeight())) {
    _keyboardVisibilityController.onChange.listen((bool visible) {
      value.visible = visible;
      if (visible) {
        value.mostRecentHeight = currentHeight();
      }
      notifyListeners();
    });
  }

  static double currentHeight() => EdgeInsets.fromWindowPadding(
          WidgetsBinding.instance!.window.viewInsets,
          WidgetsBinding.instance!.window.devicePixelRatio)
      .bottom;
}
