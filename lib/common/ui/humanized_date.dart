import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';

/// This widget dynamically humanizes a date value, updating the displayed
/// humanization when necessary as time marches on. It follows the below rules:
///
/// 1. If date is within the last minute, return 'just now'
/// 2. If date was less than 24 hours ago, return hour:minute
/// 3. If date was between 24-48 hours ago, return 'yesterday'
/// 4. Else return year/month/day, hour:minute
///
class HumanizedDate extends StatelessWidget {
  static final _hourMinuteFormat = DateFormat('jm');
  static final _weekdayFormat = DateFormat('EEEE');
  static final _ymdFormat = DateFormat('yMd');

  final DateTime dateTime;
  final DateTime localDateTime;
  final NowBuild<String> builder;

  HumanizedDate(this.dateTime, {required this.builder})
      : localDateTime = dateTime.toLocal();

  /// Convenience constructor to construct a HumanizedDate from milliseconds
  /// since epoch.
  HumanizedDate.fromMillis(int millisSinceEpoch,
      {required NowBuild<String> builder})
      : this(DateTime.fromMillisecondsSinceEpoch(millisSinceEpoch),
            builder: builder);

  @override
  Widget build(BuildContext context) {
    return NowBuilder<String>(
      calculate: (now) {
        if (localDateTime.difference(now).isNegative) {
          return past(now);
        }
        return future(now);
      },
      builder: builder,
    );
  }

  String past(DateTime now) {
    // this is within the last minute, display "just now"
    if (now.difference(localDateTime).inSeconds < 60) {
      return 'just_now'.i18n;
    }
    var roughTimeString = _hourMinuteFormat.format(dateTime);
    // this is within the current day, display time of day with AM/PM
    if (localDateTime.day == now.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return roughTimeString;
    }
    // this is within the last day, display "yesterday"
    var yesterday = now.subtract(const Duration(days: 1));
    if (localDateTime.day == yesterday.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return 'yesterday'.i18n;
    }
    // if we are less than 4 days of the message, display day name
    if (now.difference(localDateTime).inDays < 4) {
      var weekday = _weekdayFormat.format(localDateTime);
      return weekday;
    }
    // older than 4 days, switch to displaying mm/dd/yyyy date
    return _ymdFormat.format(dateTime);
  }

  String future(DateTime now) {
    if (localDateTime.difference(now).inSeconds < 60) {
      return 'within_one_minute'.i18n;
    }
    var roughTimeString = _hourMinuteFormat.format(dateTime);
    if (localDateTime.day == now.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return 'at_date'.i18n.fill([roughTimeString]);
    }
    var yesterday = now.add(const Duration(days: 1));
    if (localDateTime.day == yesterday.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return 'tomorrow'.i18n;
    }
    if (localDateTime.difference(now).inDays < 4) {
      var weekday = _weekdayFormat.format(localDateTime);
      return 'at_date'.i18n.fill(['$weekday, $roughTimeString']);
    }
    return 'at_date'
        .i18n
        .fill(['${_ymdFormat.format(dateTime)}, $roughTimeString']);
  }
}
