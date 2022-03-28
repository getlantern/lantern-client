import 'package:flutter/material.dart';
import 'package:lantern/common/ui/colors.dart';
import 'package:lantern/common/ui/custom/asset_image.dart';

// TODO: DRY we already have a PlayButton component
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
