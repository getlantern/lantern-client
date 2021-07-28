extension WaveformExtension on List<double> {
  List<double> reduceListWithAverageAndSteps(
    int _size,
    int _step,
  ) {
    var _listOfNumbers = this;
    var _listOfNumbersReduced = <double>[];
    for (var i = 0; i < _listOfNumbers.length; i += _step) {
      var _sum = 0.0;
      for (var j = 0; j < _step; j++) {
        _sum += _listOfNumbers[i + j];
      }
      _listOfNumbersReduced.add(_sum / _step);
    }
    return _listOfNumbersReduced.take(_size).toList();
  }
}

extension IntExtension on int {
  double toPercentage(int max, int min) => (this - min) / (max - min) * 100;
}
