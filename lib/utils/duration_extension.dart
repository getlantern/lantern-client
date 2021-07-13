extension DurationExtension on Duration {
  String time({bool hour = false, bool minute = false, bool seconds = false}) {
    var _time = '';
    if (hour) {
      _time += inHours <= 9 ? '0$inHours:' : '$inHours:';
    }
    if (minute) {
      _time += inMinutes <= 9 ? '0$inMinutes:' : '$inMinutes:';
    }
    if (seconds) {
      _time += inSeconds <= 9 ? '0$inSeconds' : '$inSeconds:';
    }
    return _time;
  }

  Duration calculate({Duration? inputDuration}) => (inputDuration == null ||
          compareTo(inputDuration) == 0)
      ? this
      : Duration(milliseconds: (inMilliseconds - inputDuration.inMilliseconds));
}
