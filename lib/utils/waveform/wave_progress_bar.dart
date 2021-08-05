import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lantern/utils/waveform/background_painter.dart';
import 'package:lantern/utils/waveform/single_bar_painter.dart';

class WaveProgressBar extends StatelessWidget {
  final double progressPercentage;
  final List<double> listOfHeights;
  final Alignment alignment;
  final double width;
  final Color initialColor;
  final Color progressColor;
  final Color backgroundColor;
  final double begin;

  WaveProgressBar({
    required this.listOfHeights,
    required this.initialColor,
    required this.progressColor,
    required this.backgroundColor,
    this.alignment = Alignment.center,
    this.begin = 0,
    required this.width,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    var arrayOfBars = <Widget>[];
    arrayOfBars.add(
      CustomPaint(
        painter: BackgroundBarPainter(
          containerWidth: width,
          containerHeight: listOfHeights.reduce(max),
          progresPercentage: progressPercentage,
          initialColor: initialColor,
          progressColor: progressColor,
        ),
      ),
    );

    for (var i = 0; i < listOfHeights.length; i++) {
      arrayOfBars.add(
        CustomPaint(
          painter: SingleBarPainter(
            startingPosition: i * (width / listOfHeights.length),
            singleBarWidth: width / listOfHeights.length,
            maxSeekBarHeight: listOfHeights.reduce(max) + 1,
            actualSeekBarHeight: listOfHeights[i],
            heightOfContainer: listOfHeights.reduce(max),
            backgroundColor: backgroundColor,
          ),
        ),
      );
    }

    return Container(
      height: listOfHeights.reduce(max),
      width: width,
      alignment: alignment,
      child: Row(
        children: arrayOfBars,
      ),
    );
  }
}
