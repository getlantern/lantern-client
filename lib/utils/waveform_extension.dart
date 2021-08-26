extension WaveformExtension on List<int> {
  /// Returns a new List reducing the given waveform to a 100 bars by:
  ///
  /// 1. Grouping bars into groups of size <original bars>/<target bars>
  /// 2. Taking the max bar from each group
  /// 3. Converting the amplitude into a percentage
  /// ```
  List<double> reducedWaveform({double limit = 100.0}) {
    var input = this;
    var output = <double>[];
    var groupSize = (input.length / limit).round();
    var max = 0.0;
    for (var i = 0; i < input.length; i++) {
      var value = input[i].toDouble() / 255.0 * limit;
      if (value > max) max = value;
      var next = i + 1;
      if (next % groupSize == 0 || next == input.length) {
        // record max
        output.add(max);
        max = 0;
      }
    }
    return output;
  }
}
