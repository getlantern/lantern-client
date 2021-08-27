import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

final notifications = Notifications();

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
        onSelectNotification: (payload) {
      return Future.value("dude");
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
