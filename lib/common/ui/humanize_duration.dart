extension HumanizeDuration on double {
  /// Converts a double number of seconds to MM:SS or HH:MM:SS.
  String toMinutesAndSeconds() {
    final seconds = floor();
    final duration = Duration(
      seconds: seconds,
      milliseconds: (remainder(seconds) * 1000).toInt(),
    );
    return this >= 3600
        ? duration.toString().substring(0, 7).padLeft(8, '0')
        : this >= 60
            ? duration.inMinutes >= 10
                ? duration.toString().substring(2, 7)
                : duration.toString().substring(3, 7)
            : duration.toString().substring(4, 7).padLeft(5, '0');
  }
}
