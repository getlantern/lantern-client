import 'package:intl/intl.dart';
import 'package:lantern/core/utils/common.dart';

final _hourMinuteFormat = DateFormat('jm');
final _weekdayFormat = DateFormat('EEEE');
final _ymdFormat = DateFormat('yMd');

String humanizePastFuture(DateTime now, DateTime dateTime) {
  final localDateTime = dateTime.toLocal();
  if (localDateTime.difference(now).isNegative) {
    return past(now, localDateTime, dateTime);
  }
  return future(now, localDateTime, dateTime);
}

String past(
  DateTime now,
  DateTime localDateTime,
  DateTime dateTime,
) {
  // event is within the last minute, display "just now"
  if (now.difference(localDateTime).inSeconds < 60) {
    return 'just_now'.i18n;
  }
  var roughTimeString = _hourMinuteFormat.format(dateTime);
  // event is within the current calendar day, display time of day with AM/PM
  if (localDateTime.day == now.day &&
      localDateTime.month == now.month &&
      localDateTime.year == now.year) {
    return roughTimeString;
  }
  // event is within the last calendar day, display "yesterday"
  var yesterday = now.subtract(const Duration(days: 1));
  if (localDateTime.day == yesterday.day &&
      localDateTime.month == now.month &&
      localDateTime.year == now.year) {
    return 'yesterday'.i18n;
  }
  // less than 4 calendar days have elapsed since event, display day name e.g. "Friday"
  if (now.difference(localDateTime).inDays < 4) {
    var weekday = _weekdayFormat.format(localDateTime);
    return weekday;
  }
  // event is older than 4 days, switch to displaying mm/dd/yyyy date
  return _ymdFormat.format(dateTime);
}

String future(
  DateTime now,
  DateTime localDateTime,
  DateTime dateTime,
) {
  // event will be within the next minute, display "within one minute"
  if (localDateTime.difference(now).inSeconds < 60) {
    return 'within_one_minute'.i18n;
  }
  // event will occur by EOD today, display time of day with AM/PM
  var roughTimeString = _hourMinuteFormat.format(dateTime);
  if (localDateTime.day == now.day &&
      localDateTime.month == now.month &&
      localDateTime.year == now.year) {
    return 'at_date'.i18n.fill([roughTimeString]);
  }
  // event will occur less than one calendar day from now, display "tomorrow"
  var tomorrow = DateTime(now.year, now.month, now.day + 1);
  if (localDateTime.year == tomorrow.year &&
      localDateTime.month == tomorrow.month &&
      localDateTime.day == tomorrow.day) {
    return 'tomorrow'.i18n;
  }
  // event will occur less than 4 days from now, display "on Tuesday, at 4:30pm"
  if (localDateTime.difference(now).inDays < 4) {
    var weekday = _weekdayFormat.format(localDateTime);
    return 'on_date'.i18n.fill([weekday]) +
        ', ' +
        'at_date'.i18n.fill([roughTimeString]);
  }
  // event will occur far in the future, display "on 12/12/2024, at 5:30AM"
  return 'on_date'.i18n.fill([_ymdFormat.format(dateTime)]) +
      ', ' +
      'at_date'.i18n.fill([roughTimeString]);
}
