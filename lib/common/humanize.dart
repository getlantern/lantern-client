import 'package:intl/intl.dart';

/// Based on https://www.flutterclutter.dev/flutter/tutorials/date-format-dynamic-string-depending-on-how-long-ago/2020/229/
extension Humanize on int {
  String humanizeDate() {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(this);
    var now = DateTime.now();
    var justNow = now.subtract(const Duration(minutes: 1));
    var localDateTime = dateTime.toLocal();
    if (!localDateTime.difference(justNow).isNegative) {
      return 'just now'; // TODO: use i18n
    }
    var roughTimeString = DateFormat('jm').format(dateTime);
    if (localDateTime.day == now.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return roughTimeString;
    }
    var yesterday = now.subtract(const Duration(days: 1));
    if (localDateTime.day == yesterday.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return 'Yesterday'; // TODO: use i18n
    }
    if (now.difference(localDateTime).inDays < 4) {
      var weekday = DateFormat('EEEE').format(localDateTime);
      return '$weekday, $roughTimeString';
    }
    return '${DateFormat('yMd').format(dateTime)}, $roughTimeString';
  }

  String humanizeSeconds({bool longForm = false}) {
    // TODO: unit test this
    if (this < 60) {
      return toString() + (longForm ? ' seconds' : 's'); // TODO: add i18n
    }
    if (this < 3600) {
      return (this ~/ 60).toString() +
          (longForm
              ? ' minute${(this ~/ 60) > 1 ? 's' : ''}'
              : 'm'); // TODO: add i18n
    }
    if (this < 86400) {
      return (this ~/ 3600).toString() +
          (longForm
              ? ' hour${(this ~/ 3600) > 1 ? 's' : ''}'
              : 'h'); // TODO: add i18n
    }
    if (this < 604800) {
      return (this ~/ 86400).toString() +
          (longForm
              ? ' day${(this ~/ 86400) > 1 ? 's' : ''}'
              : 'd'); // TODO: add i18n
    }
    if (this < 2629800) {
      return (this ~/ 604800).toString() +
          (longForm
              ? ' week${(this ~/ 604800) > 1 ? 's' : ''}'
              : 'd'); // TODO: add i18n
    }
    return (this ~/ 604800).toString() +
        (longForm
            ? ' week${(this ~/ 604800) > 1 ? 's' : ''}'
            : 'd'); // TODO: add i18n
  }
}
