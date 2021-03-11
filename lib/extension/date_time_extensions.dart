import 'package:fixnum/fixnum.dart';
import '../model/protos/messaging.pb.dart';
import '../i18n/i18n.dart';

extension DateTimeExtension on Timestamp {
  DateTime toDateTime() {
    return DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch.toInt());
  }
}

extension TimestampExtension on DateTime {
  Timestamp toTimestamp() {
    var ts = Timestamp.create();
    ts.microsecondsSinceEpoch = Int64(microsecondsSinceEpoch);
    return ts;
  }
}

extension DurationExtension on Duration {
  String get humanized {
    var days = inDays;
    if (days > 0) {
      return days.toString() + " " + "days".i18n;
    }
    var hours = inHours;
    if (hours > 0) {
      return hours.toString() + " " + "hours".i18n;
    }
    var minutes = inMinutes;
    if (minutes > 0) {
      return minutes.toString() + " " + "minutes".i18n;
    }
    return inSeconds.toString() + " " + "seconds".i18n;
  }
}