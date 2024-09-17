import 'package:lantern/core/utils/common.dart';

/// This widget dynamically humanizes a date value, updating the displayed
/// humanization when necessary as time marches on. It follows the below rules:
///
/// 1. If date is within the last minute, return 'just now'
/// 2. If date was less than 24 hours ago, return hour:minute
/// 3. If date was between 24-48 hours ago, return 'yesterday'
/// 4. Else return year/month/day, hour:minute
///
class HumanizedDate extends StatelessWidget {
  final DateTime dateTime;
  final DateTime localDateTime;
  final NowBuild<String> builder;

  HumanizedDate(this.dateTime, {required this.builder})
      : localDateTime = dateTime.toLocal();

  /// Convenience constructor to construct a HumanizedDate from milliseconds
  /// since epoch.
  HumanizedDate.fromMillis(
    int millisSinceEpoch, {
    required NowBuild<String> builder,
  }) : this(
          DateTime.fromMillisecondsSinceEpoch(millisSinceEpoch),
          builder: builder,
        );

  @override
  Widget build(BuildContext context) {
    return NowBuilder<String>(
      calculate: (now) => humanizePastFuture(
        now,
        dateTime,
      ),
      builder: builder,
    );
  }
}
