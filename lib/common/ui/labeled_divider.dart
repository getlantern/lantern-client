import 'package:lantern/common/common.dart';

class LabeledDivider extends StatelessWidget {
  late final String? label;
  late final CTextStyle? labelStyle;
  late final EdgeInsetsGeometry? padding;
  late final double height;

  LabeledDivider(
      {Key? key, this.label, this.labelStyle, this.padding, this.height = 20})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var divider = SizedBox(
      height: height,
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
                child: CText(
                  label!,
                  style: labelStyle ??
                      CTextStyle(
                          color: Colors.black, fontSize: 12, lineHeight: 12),
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
