import 'common.dart';

/// Disables the system back button. This is often called inside of
/// [State.initState]. Make sure to call [enableBackButton] when you want to
/// allow the back button to work again, for example in [State.dispose].
void disableBackButton() {
  BackButtonInterceptor.add(_doNotGoBack);
}

void enableBackButton() {
  BackButtonInterceptor.remove(_doNotGoBack);
}

bool _doNotGoBack(bool stopDefaultButtonEvent, RouteInfo info) => true;
