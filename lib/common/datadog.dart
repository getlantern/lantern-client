import 'package:datadog_flutter_plugin/datadog_flutter_plugin.dart';
import 'package:datadog_tracking_http_client/datadog_tracking_http_client.dart';

class Datadog {
  static final DatadogSdk _instance = DatadogSdk.instance;

  static trackUserTap(String message, [Map<String, Object?> attributes = const {}]) {
    _instance.rum?.addUserAction(RumUserActionType.tap, message, attributes);
  }

  static trackUserCustom(String message, [Map<String, Object?> attributes = const {}]) {
    _instance.rum?.addUserAction(RumUserActionType.custom, message, attributes);
  }

  // Notifies Datadog that an Exception or Error [error] occurred in the currently
  // presented View
  static addError(
    Object error, {
    StackTrace? st,
    Map<String, Object?> attributes = const {},
  }) {
    _instance.rum?.addErrorInfo(
      error.toString(),
      RumErrorSource.source,
      stackTrace: st,
      attributes: attributes,
    );
  }
}
