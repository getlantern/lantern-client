import 'package:lantern/common/common.dart';

//// A TextButton with our standard styling
class Button extends StatelessWidget {
  late final String text;
  late final String? iconPath;
  late final void Function()? onPressed;
  late final double? width;
  late final bool primary;
  late final bool secondary;
  late final bool disabled;
  late final bool tertiary;

  Button(
      {required this.text,
      this.iconPath,
      this.onPressed,
      this.width,
      this.primary = true,
      this.secondary = false,
      this.disabled = false,
      this.tertiary = false});

  void _handleOnPress() {
    if (disabled) return null;
    return onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: width,
      child: OutlinedButton(
        onPressed: _handleOnPress,
        style: OutlinedButton.styleFrom(
          splashFactory:
              disabled ? NoSplash.splashFactory : InkSplash.splashFactory,
          backgroundColor: getBgColor(secondary, disabled, tertiary),
          padding: const EdgeInsets.symmetric(vertical: 15),
          side: BorderSide(width: 2, color: getBorderColor(disabled, tertiary)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconPath != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: CAssetImage(
                    path: iconPath!,
                    color: white,
                  ),
                ),
              CText(
                text.toUpperCase(),
                // style: disabled ? tsButtonGrey : tsButtonWhite,
                style: getTextStyle(secondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
