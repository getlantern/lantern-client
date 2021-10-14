import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lantern/messaging/messaging.dart';

final notifications = Notifications();
final JsonEncoder _encoder = const JsonEncoder();
final JsonDecoder _decoder = const JsonDecoder();

class Notifications {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final inCallChannel = const NotificationDetails(
    android: AndroidNotificationDetails(
        '10003', 'in_call', 'Notification of ongoing call',
        importance: Importance.max, priority: Priority.high, showWhen: false),
  );

  Notifications() {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final initializationSettings =
        const InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payloadString) {
      if (payloadString?.isNotEmpty == true) {
        var payload = Payload.fromJson(payloadString!);
        switch (payload.type) {
          case PayloadType.ringing:
            Map<String, dynamic> data = payload.data;
            messagingModel.signaling.onMessage(
                data['peerId'], data['messageJson'], false,
                ring: false);
            break;
        }
      }
      return Future.value(null);
    });
  }

  Future<void> showInCallNotification(Contact contact) {
    return flutterLocalNotificationsPlugin.show(
        0,
        'In call with ${contact.displayName}'.i18n,
        'Touch here to open call'.i18n,
        inCallChannel);
  }
}

class PayloadType {
  static const ringing = 'ringing';
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
