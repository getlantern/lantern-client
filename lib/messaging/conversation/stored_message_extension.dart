import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';

extension StoredMessageExtension on StoredMessage {
  /// Returns a `List<int>` with the time segments
  List<int> segments({int iterations = 0}) {
    var segments = <int>[];
    var totalTime = (disappearAt - firstViewedAt).toInt();
    int timePerSegment;

    /// if the calculation gave an error then we can safely assume that the
    /// timePerSegment is gonna be always 0.
    try {
      timePerSegment = (totalTime ~/ iterations);
    } catch (_) {
      timePerSegment = 0;
    }

    /// Once we have the time per segment, we iterate and check if the array is
    /// empty (only on first position) then we just sum the current value, if
    /// not then we retrieve the previous position and just add it to the next
    /// iteration.
    for (var i = 0; i < iterations; i++) {
      segments.isEmpty
          ? segments.add(firstViewedAt.toInt() + timePerSegment)
          : segments.add(segments[i - 1] + timePerSegment);
    }
    return segments;
  }

  /// return the position of the element, based on a list of integers.
  int position({required List<int> segments}) {
    var currentTime = DateTime.now().millisecondsSinceEpoch;
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
