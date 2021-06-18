extension IntExtension on int {
  /// Returns a `List<int>` with the time segments
  List<int> segments({int iterations = 0, required int endTime}) {
    var segments = <int>[];
    var totalTime = (endTime - this);
    int timePerSegment;

    /// if the calculation gave an error then we can safetly asumme that the  timePerSegment
    /// is gonna be always 0.
    try {
      timePerSegment = (totalTime ~/ iterations);
    } catch (_) {
      timePerSegment = 0;
    }

    /// Once we have the time per segment, we iterate and check if the array is empty (only on first position) then
    /// we just sum the current value, if not then we retrieve the previous position and just add it to the next iteration.
    for (var i = 0; i < iterations; i++) {
      segments.isEmpty
          ? segments.add(this + timePerSegment)
          : segments.add(segments[i - 1] + timePerSegment);
    }
    return segments;
  }

  /// return the position of the element, based on a list of integers.
  int position({required List<int> segments, int extraTime = 0}) {
    var currentTime = extraTime != 0 ? (this + extraTime) : this;
    var position = 0;
    for (var i = 0; i < segments.length; i++) {
      if (currentTime < segments[i]) {
        position = i;
        break;
      }
    }
    return position;
  }
}
