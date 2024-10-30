import 'package:lantern/features/messaging/messaging.dart';

const barWidth = 2.0;
const barPlusSpaceWidth = 2 * barWidth;

class Waveform extends StatelessWidget {
  final double progressPercentage;
  final List<double> bars;
  final double width;
  final double height;
  final Color initialColor;
  final Color progressColor;

  Waveform({
    required List<int> bars,
    required this.initialColor,
    required this.progressColor,
    required this.width,
    required this.height,
    required this.progressPercentage,
  }) : bars = _reducedAndNormalized(bars, width, height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CustomPaint(
        painter: _BarsPainter(
          bars: bars,
          height: height,
          progressedTo: width * progressPercentage / 100,
          initialColor: initialColor,
          progressColor: progressColor,
        ),
      ),
    );
  }

  /// The input bars are approximately 1000 samples of between 0 to 255.
  ///
  /// This function reduces this into the number of bars that will fit into this
  /// widget's width by bucketing the samples and taking the max amplitude from
  /// each bucket. It also scales the values to the height of the widget.
  static List<double> _reducedAndNormalized(
    List<int> bars,
    double width,
    double height,
  ) {
    final numberOfBars = (width + barWidth) ~/ barPlusSpaceWidth;
    var output = <double>[];
    var groupSize = (bars.length / numberOfBars).round();
    var max = 0.0;
    for (var i = 0; i < bars.length; i++) {
      var value = bars[i].toDouble() / 255.0 * height;
      if (value > max) max = value;
      var next = i + 1;
      if (next % groupSize == 0 || next == bars.length) {
        // record max
        output.add(max);
        max = 0;
      }
    }
    return output;
  }
}

class _BarsPainter extends CustomPainter {
  final List<double> bars;
  final double height;
  final double progressedTo;
  final Paint initialPaint;
  final Paint progressPaint;

  _BarsPainter({
    required this.bars,
    required this.height,
    required this.progressedTo,
    required Color initialColor,
    required Color progressColor,
  })  : initialPaint = Paint()
          ..color = initialColor
          ..style = PaintingStyle.fill,
        progressPaint = Paint()
          ..color = progressColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < bars.length; i++) {
      final startingPosition = i * barPlusSpaceWidth;
      var barHeight = min(-1 * bars[i], -1).toDouble();
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
            startingPosition,
            height,
            barWidth,
            barHeight,
          ),
          topLeft: const Radius.circular(1),
          topRight: const Radius.circular(1),
        ),
        progressedTo > startingPosition ? progressPaint : initialPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
