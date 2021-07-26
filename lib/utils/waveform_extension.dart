extension WaveformExtension on List<double> {
  List<double> reduceList(int factor) {
    var _reduced = <double>[];
    var _counter = 0.0;
    for (var _element in this) {
      if (_counter % factor == 0) {
        _reduced.add(_element);
      }
      _counter++;
    }
    return _reduced;
  }
}

extension IntExtension on int {
  double toPercentage(int max, int min) => (this - min) / (max - min) * 100;
}
