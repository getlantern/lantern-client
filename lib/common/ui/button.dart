import 'package:lantern/common/common.dart';

//// A TextButton with our standard styling
class Button extends StatelessWidget {
  late final String text;
  late final String? iconPath;
  late final void Function()? onPressed;
  late final double? width;
  late final bool secondary;
  late final bool disabled;

  Button(
      {required this.text,
      this.iconPath,
      this.onPressed,
      this.width,
      this.secondary = false,
      this.disabled = false});

  void _handleOnPress() {
    if (disabled) return null;
    return onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.7 : 1,
      child: SizedBox(
        height: 56,
        width: width,
        child: OutlinedButton(
          onPressed: _handleOnPress,
          style: OutlinedButton.styleFrom(
            splashFactory:
                disabled ? NoSplash.splashFactory : InkSplash.splashFactory,
            backgroundColor: disabled
                ? grey3
                : secondary
                    ? white
                    : primaryPink,
            padding: const EdgeInsets.symmetric(vertical: 15),
            side: BorderSide(width: 2, color: disabled ? grey5 : primaryPink),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CText(
                  text.toUpperCase(),
                  // style: disabled ? tsButtonGrey : tsButtonWhite,
                  style: disabled
                      ? tsButtonGrey
                      : secondary
                          ? tsButtonPink
                          : tsButtonWhite,
                  textAlign: TextAlign.center,
                ),
                if (iconPath != null) const SizedBox(width: 5),
                if (iconPath != null)
                  CAssetImage(
                    path: iconPath!,
                    color: Colors.white,
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
