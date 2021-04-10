import 'package:intl/intl.dart';

/// Based on https://www.flutterclutter.dev/flutter/tutorials/date-format-dynamic-string-depending-on-how-long-ago/2020/229/
extension Humanize on int {
  String humanizeDate() {
    DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(this ~/ 1000);
    DateTime now = DateTime.now();
    DateTime justNow = now.subtract(Duration(minutes: 1));
    DateTime localDateTime = dateTime.toLocal();
    if (!localDateTime.difference(justNow).isNegative) {
      return 'just now'; // TODO: use i18n
    }
    String roughTimeString = DateFormat('jm').format(dateTime);
    if (localDateTime.day == now.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return roughTimeString;
    }
    DateTime yesterday = now.subtract(Duration(days: 1));
    if (localDateTime.day == yesterday.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return 'Yesterday';
    }
    if (now.difference(localDateTime).inDays < 4) {
      String weekday = DateFormat('EEEE').format(localDateTime);
      return '$weekday, $roughTimeString';
    }
    return '${DateFormat('yMd').format(dateTime)}, $roughTimeString';
  }

  String humanizeSeconds({bool longForm = false}) {
    // TODO: unit test this
    // TODO: localize the string portions of the below
    if (this < 60) {
      return this.toString() + (longForm ? ' seconds' : 's');
    }
    if (this < 3600) {
      return (this ~/ 60).toString() + (longForm ? ' minutes' : 'm');
    }
    if (this < 86400) {
      return (this ~/ 3600).toString() + (longForm ? ' hours' : 'h');
    }
    return (this ~/ 86400).toString() + (longForm ? ' days' : 'd');
  }
}
