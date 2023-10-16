import 'package:plausible_analytics/plausible_analytics.dart';

class PlausibleUtils {
  static trackUserAction(String name, [Map<String, String> props = const {}]) {
    Plausible plausible =
        Plausible("https://plausible.io", "android.lantern.io");
    // Send goal
    plausible.event(name: name, props: props);
  }
}
