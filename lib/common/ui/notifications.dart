import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lantern/app.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

final notifications = Notifications();

final JsonEncoder _encoder = const JsonEncoder();
final JsonDecoder _decoder = const JsonDecoder();

class Notifications {
  int _notificationId = 0;

  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final _ringingChannel = const NotificationDetails(
    android: AndroidNotificationDetails(
      '10002',
      'ringing',
      'Ring on incoming call',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      showWhen: false,
    ),
  );

  final _inCallChannel = const NotificationDetails(
    android: AndroidNotificationDetails(
        '10003', 'in_call', 'Notification of ongoing call',
        importance: Importance.high, priority: Priority.high, showWhen: false),
  );

  Notifications() {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final initializationSettings =
        const InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payloadString) {
      if (payloadString?.isNotEmpty == true) {
        var payload = Payload.fromJson(payloadString!);
        switch (payload.type) {
          case PayloadType.ringing:
            Map<String, dynamic> data = payload.data;
            messagingModel.signaling
                .onMessage(data['peerId'], data['messageJson'], ring: false);
            break;
        }
      }

      return Future.value(null);
    });
  }

  Future<void> showRingingNotification(
      Contact contact, String peerId, String messageJson) {
    final id = _notificationId++;
    var payload = Payload(type: PayloadType.ringing, data: {
      'peerId': peerId,
      'messageJson': messageJson,
    });
    return _flutterLocalNotificationsPlugin
        .show(
            _notificationId++,
            'incoming_call_from'.i18n.fill([contact.displayName]),
            'touch_here_to_open_call'.i18n,
            _ringingChannel,
            payload: payload.toJson())
        .then((value) => id);
  }

  Future<int> showInCallNotification(Contact contact) {
    final id = _notificationId++;
    return _flutterLocalNotificationsPlugin
        .show(id, 'in_call_with'.i18n.fill([contact.displayName]),
            'touch_here_to_open_call'.i18n, _inCallChannel)
        .then((value) => id);
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
