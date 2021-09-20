/// Based on https://www.flutterclutter.dev/flutter/tutorials/date-format-dynamic-string-depending-on-how-long-ago/2020/229/
extension Humanize on int {
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
              : 'w'); // TODO: add i18n
    }
    return (this ~/ 604800).toString() +
        (longForm
            ? ' week${(this ~/ 604800) > 1 ? 's' : ''}'
            : 'd'); // TODO: add i18n
  }
}
