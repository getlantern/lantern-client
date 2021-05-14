import 'package:lantern/package_store.dart';

class CustomDivider extends StatelessWidget {
  late final String? label;
  late final TextStyle? labelStyle;
  late final EdgeInsets? padding;

  CustomDivider({Key? key, this.label, this.labelStyle, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var divider = SizedBox(
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Container(
              color: borderColor,
              height: 1,
            ),
          ),
          if (label != null)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                color: Colors.white,
                child: Text(
                  label!,
                  style: labelStyle ??
                      const TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );

    if (padding != null) {
      return Container(padding: padding, child: divider);
    } else {
      return divider;
    }
  }
}
