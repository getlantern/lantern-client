import 'package:intl/intl.dart';
import 'package:lantern/package_store.dart';

import 'now_builder.dart';

class HumanizedDate extends StatelessWidget {
  static final _hourMinuteFormat = DateFormat('jm');
  static final _weekdayFormat = DateFormat('EEEE');
  static final _ymdFormat = DateFormat('yMd');

  final DateTime dateTime;
  final DateTime localDateTime;
  final NowBuild<String> builder;

  HumanizedDate(this.dateTime, {required this.builder})
      : localDateTime = dateTime.toLocal();

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
          return 'justnow'.i18n;
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
