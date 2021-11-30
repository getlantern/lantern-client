import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lantern/messaging/messaging.dart';

final JsonEncoder _encoder = const JsonEncoder();
final JsonDecoder _decoder = const JsonDecoder();

class Notifications {
  static final inCallNotificationId = 0;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final inCallChannel = NotificationDetails(
    android: AndroidNotificationDetails(
        '10003', 'in_call'.i18n, 'in_call_des'.i18n,
        importance: Importance.max, priority: Priority.high, showWhen: false),
  );

  Notifications(this.selectionCallback) {
    flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
            android: AndroidInitializationSettings('app_icon')),
        onSelectNotification: selectionCallback);
  }
  SelectNotificationCallback? selectionCallback;

  Future<void> showInCallNotification(Contact contact) {
    return flutterLocalNotificationsPlugin.show(
        inCallNotificationId,
        'in_call_with'.i18n.fill([contact.displayName]),
        'touch_here_to_open_call'.i18n,
        inCallChannel);
  }

  Future<void> dismissInCallNotification() {
    return flutterLocalNotificationsPlugin.cancel(inCallNotificationId);
  }
}

class PayloadType {
  static const ringing = 'ringing';
  static const download = 'download';
}

class Payload {
  late String type;
  late dynamic data;

  Payload({required this.type, required this.data});

  Payload.fromJson(String json) {
    var parsed = _decoder.convert(json);
    type = parsed['type'];
    data = parsed['data'];
  }

  String toJson() {
    return _encoder.convert({'type': type, 'data': data});
  }
}
