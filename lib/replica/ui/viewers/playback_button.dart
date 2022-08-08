import 'package:flutter/material.dart';
import 'package:lantern/common/ui/colors.dart';
import 'package:lantern/common/ui/custom/asset_image.dart';

// TODO <08-08-22, kalli> We probably won't need this if we shift to using the audio components from messaging
class PlaybackButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final String path;
  final double size;

  PlaybackButton({
    Key? key,
    required this.onTap,
    required this.path,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: black,
          shape: BoxShape.circle,
        ),
        child: CAssetImage(
          path: path,
        ),
      ),
    );
  }
}
