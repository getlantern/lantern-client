import 'package:lantern/features/messaging/messaging.dart';

/// Based on https://www.flutterclutter.dev/flutter/tutorials/date-format-dynamic-string-depending-on-how-long-ago/2020/229/
extension Humanize on int {
  // TODO: do we need to humanize numbers as well?
  String humanizeSeconds({bool longForm = false}) {
    var result;
    // seconds
    if (this < 60) {
      return longForm
          ? 'longform_seconds'.i18n.fill([toString()])
          : 'shortform_seconds'.i18n.fill([toString()]);
    }
    // minutes
    if (this < 3600) {
      result = (this ~/ 60);
      return longForm
          ? result > 1
              ? 'longform_minutes'.i18n.fill([result.toString()])
              : 'longform_minute'.i18n.fill([result.toString()])
          : 'shortform_minutes'.i18n.fill([result.toString()]);
    }
    // hours
    if (this < 86400) {
      result = (this ~/ 3600);
      return longForm
          ? result > 1
              ? 'longform_hours'.i18n.fill([result.toString()])
              : 'longform_hour'.i18n.fill([result.toString()])
          : 'shortform_hours'.i18n.fill([result.toString()]);
    }
    // days
    if (this < 604800) {
      result = (this ~/ 86400);
      return longForm
          ? result > 1
              ? 'longform_days'.i18n.fill([result.toString()])
              : 'longform_day'.i18n.fill([result.toString()])
          : 'shortform_days'.i18n.fill([result.toString()]);
    }
    // weeks (less than a month)
    if (this < 2629800) {
      result = (this ~/ 604800);
      return longForm
          ? result > 1
              ? 'longform_weeks'.i18n.fill([result.toString()])
              : 'longform_week'.i18n.fill([result.toString()])
          : 'shortform_weeks'.i18n.fill([result.toString()]);
    }
    // weeks (more than a month)
    if (longForm) {
      result = this ~/ 604800;
      return result > 1
          ? 'longform_weeks'.i18n.fill([result.toString()])
          : 'longform_week'.i18n.fill([result.toString()]);
    }
    result = this ~/ 86400;
    return 'shortform_days'.i18n.fill([result.toString()]);
  }
}
