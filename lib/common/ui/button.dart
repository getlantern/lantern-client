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

  Button({
    required this.text,
    this.iconPath,
    this.onPressed,
    this.width,
    this.primary = true,
    this.secondary = false,
    this.disabled = false,
    this.tertiary = false,
  });

  void _handleOnPress() {
    return onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      constraints: BoxConstraints(minWidth: width ?? 200.0),
      child: OutlinedButton(
        onPressed: disabled?null:_handleOnPress,
        style: OutlinedButton.styleFrom(
          splashFactory:
              disabled ? NoSplash.splashFactory : InkSplash.splashFactory,
          backgroundColor: getBgColor(secondary, disabled, tertiary),
          padding: const EdgeInsetsDirectional.only(top: 15, bottom: 15),
          side: BorderSide(width: 2, color: getBorderColor(disabled, tertiary)),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 23, end: 23),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconPath != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: CAssetImage(
                    path: iconPath!,
                    color: !secondary ? white : !disabled ? pink4 : grey5,
                  ),
                ),
              Expanded(
                flex: 0,
                child: CText(
                  text.toUpperCase(),
                  style: getTextStyle(secondary, disabled),
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
