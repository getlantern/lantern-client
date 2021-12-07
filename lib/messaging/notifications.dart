import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lantern/messaging/messaging.dart';

final JsonEncoder _encoder = const JsonEncoder();
final JsonDecoder _decoder = const JsonDecoder();

class Notifications {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final inCallChannel = const NotificationDetails(
    android: AndroidNotificationDetails('10003', 'in_call',
        channelDescription: 'Ongoing calls',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false),
  );
  final downloadChannel = const NotificationDetails(
    android: AndroidNotificationDetails('10004', 'download',
        channelDescription: 'Downloads',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false),
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
        0,
        'In call with ${contact.displayName}'.i18n,
        'Touch here to open call'.i18n,
        inCallChannel);
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
