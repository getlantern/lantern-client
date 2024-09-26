import 'package:lantern/core/utils/common.dart';

//// A TextButton with our standard styling
class Button extends StatelessWidget {
   final String text;
   final String? iconPath;
   final void Function()? onPressed;
   final double? width;
   final bool primary;
   final bool secondary;
   final bool disabled;
   final bool tertiary;

  const Button({super.key,
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
        onPressed: disabled ? null : _handleOnPress,
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
                    color: !secondary
                        ? white
                        : !disabled
                            ? pink4
                            : grey5,
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

class AppTextButton extends StatelessWidget {
  final String text;
  void Function()? onPressed;
  Color? color;

  AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? pink5,
      ),
      child: Text(text),
    );
  }
}
