extension WaveformExtension on List<double> {
  /// Returns a a new list with the average values of a group of numbers `steps` taken from the list.
  /// ```dart
  /// var list = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0];
  /// list.reduceListWithAverageAndSteps(5, 2) => [1.5, 3.5, 5.5, 7.5, 9.5])
  /// ```
  List<double> reduceListWithAverageAndSteps(
    int _size,
    int _step,
  ) {
    var _listOfNumbers = this;
    var _listOfNumbersReduced = <double>[];
    // Iterate over the list of numbers
    for (var i = 0; i < _listOfNumbers.length; i += _step) {
      // Get the average of the numbers in the current group
      // and add it to the list of numbers reduced
      var _sum = 0.0;
      // Iterate over the numbers in the current group
      for (var j = 0; j < _step; j++) {
        // Add the current number to the sum
        _sum += _listOfNumbers[i + j];
      }
      _listOfNumbersReduced.add(_sum / _step);
    }
    // Return the list of numbers reduced
    return _listOfNumbersReduced.take(_size).toList();
  }
}

extension IntExtension on int {
  double toPercentage(int max, int min) => (this - min) / (max - min) * 100;
}
