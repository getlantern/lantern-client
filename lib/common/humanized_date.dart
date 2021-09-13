import 'package:intl/intl.dart';
import 'package:lantern/package_store.dart';

import 'now_builder.dart';

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
        var justNow = now.subtract(const Duration(minutes: 1));
        if (!localDateTime.difference(justNow).isNegative) {
          return 'just_now'.i18n;
        }
        var roughTimeString = _hourMinuteFormat.format(dateTime);
        if (localDateTime.day == now.day &&
            localDateTime.month == now.month &&
            localDateTime.year == now.year) {
          return roughTimeString;
        }
        var yesterday = now.subtract(const Duration(days: 1));
        if (localDateTime.day == yesterday.day &&
            localDateTime.month == now.month &&
            localDateTime.year == now.year) {
          return 'yesterday'.i18n;
        }
        if (now.difference(localDateTime).inDays < 4) {
          var weekday = _weekdayFormat.format(localDateTime);
          return '$weekday, $roughTimeString';
        }
        return '${_ymdFormat.format(dateTime)}, $roughTimeString';
      },
      builder: builder,
    );
  }
}
