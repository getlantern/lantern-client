extension HumanizeDuration on double {
  /// Converts a double number of seconds to MM:SS or HH:MM:SS.
  String toMinutesAndSeconds() {
    // TODO: something is wrong here
    if (this >= 3600) {
      return toString().split('.').first.padLeft(8, '0');
    }
    final seconds = floor();
    final duration = Duration(
      seconds: seconds,
      milliseconds: (remainder(seconds) * 1000).toInt(),
    );
    return duration.toString().substring(2, 7);
  }
}
