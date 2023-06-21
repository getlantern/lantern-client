import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:lantern/replica/models/replica_link.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';

final notifications = Notifications();
final JsonEncoder _encoder = const JsonEncoder();
final JsonDecoder _decoder = const JsonDecoder();

var logger = Logger(
  printer: PrettyPrinter(),
);

class Notifications {
  static final inCallNotificationId = 0;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final inCallChannel = NotificationDetails(
    android: AndroidNotificationDetails(
      '10003',
      'in_call'.i18n,
      channelDescription: '_call_des'.i18n,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    ),
  );

  NotificationDetails getUploadCompleteChannel(UploadTaskResponse resp) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        '10004',
        'upload'.i18n,
        channelDescription: 'upload_des'.i18n,
        importance: Importance.high,
        icon: 'ic_upload',
        priority: Priority.high,
        showWhen: false,
      ),
    );
  }

  NotificationDetails getUploadProgressChannel(int progress) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        '10004',
        'upload'.i18n,
        channelDescription: 'upload_des'.i18n,
        importance: Importance.max,
        progress: progress,
        showProgress: true,
        maxProgress: 100,
        onlyAlertOnce: true,
        icon: 'ic_upload',
        priority: Priority.high,
        showWhen: false,
      ),
    );
  }

  Notifications() {
    flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('app_icon'),
      ),
      onSelectNotification: (payloadString) async {
        if (payloadString?.isNotEmpty == true) {
          var payload = Payload.fromJson(payloadString!);
          switch (payload.type) {
            // case PayloadType.Ringing:
            //   Map<String, dynamic> data = payload.data;
            //   messagingModel.signaling
            //       .onMessage(data['peerId'], data['messageJson'], false);
            //   break;
            // TODO <16-12-2021> soltzen: This code does not work as of today:
            // The notification click events are not being processed. This'll be
            // addressed here: https://github.com/getlantern/lantern-internal/issues/5133
            // TODO <08-10-22, kalli> Building on above comment:
            // While we are technically close to being able to share replica links, there are big pieces missing from how this can meaningfully and safely be put in production. Some concerns involve handling cases where someone doesn't know or use Lantern, as well as sharing increasing censor attack exposure area. More context: https://github.com/getlantern/lantern-internal/issues/3577
            case PayloadType.Upload:
              // The payload here is a possible JSON response body
              // See ReplicaUploader for more info on this payload type
              try {
                Map<String, dynamic> resp = jsonDecode(payload.data);
                if (!resp.containsKey('replicaLink')) {
                  return;
                }
                // XXX <16-12-2021> soltzen: we don't care much for the other
                // parameters, but they are here for reference:
                // https://github.com/getlantern/replica/blob/c61b1855475391c715a1e8e370da87b31848d514/server/object.go#L12
                var link = ReplicaLink.New(resp['replicaLink']);
                if (link == null) {
                  // TODO <08-22-22, kalli> Don't throw exception directly
                  throw Exception('Replicalink.New() failed');
                }
                // Prompt the user a Share dialog
                await Share.share('replica://${link.toMagnetLink()}');
              } catch (ex) {
                logger.w(
                  'Failed to decode upload json resp: ${payload.data}. Will not process upload notification clicks. Err: $ex',
                );
              }
              break;
            default:
              break;
          }
        }
        return;
      },
    );
  }

  Future<void> showInCallNotification(Contact contact) {
    return flutterLocalNotificationsPlugin.show(
      inCallNotificationId,
      'in_call_with'.i18n.fill([contact.displayName]),
      'touch_here_to_open_call'.i18n,
      inCallChannel,
    );
  }

  Future<void> dismissInCallNotification() {
    return flutterLocalNotificationsPlugin.cancel(inCallNotificationId);
  }
}

enum PayloadType { Ringing, Upload }

extension ToShortString on PayloadType {
  String toShortString() {
    return toString().split('.').last;
  }
}

class Payload {
  late PayloadType type;
  late dynamic data;

  Payload({required this.type, required this.data});

  Payload.fromJson(String json) {
    var parsed = _decoder.convert(json);
    type = PayloadType.values
        .firstWhere((e) => e.toShortString() == parsed['type']);
    data = parsed['data'];
  }

  String toJson() {
    return _encoder.convert({'type': type.toShortString(), 'data': data});
  }
}
