import 'package:datadog_flutter_plugin/datadog_flutter_plugin.dart';
import 'package:datadog_tracking_http_client/datadog_tracking_http_client.dart';

class Datadog {
  static final DatadogSdk _instance = DatadogSdk.instance;

  static trackUserTap(String message) {
    _instance.rum?.addUserAction(RumUserActionType.tap, message);
  }

  static trackUserCustom(String message) {
    _instance.rum?.addUserAction(RumUserActionType.custom, message);
  }

  /// Notifies that the Exception or Error [error] occurred in currently
  /// presented View, with an origin of [source].
  static addError(
    Object e, {
    StackTrace? st,
    Map<String, Object?> attributes = const {},
  }) {
    _instance.rum?.addErrorInfo(
      e.toString(),
      RumErrorSource.source,
      stackTrace: st,
      attributes: attributes,
    );
  }
}
