import 'package:lantern/common/common.dart';

//// This a custom TextField that renders a label in its outline, aligned with
//// the prefix icon. We don't use the default behavior of OutlineInputBorder
//// because it aligns the label to the right of the prefix icon, in
//// contravention of the Material design specification.
class CTextField extends StatefulWidget {
  late final CustomTextEditingController controller;
  late final String? initialValue;
  late final String label;
  late final String? helperText;
  late final String? hintText;
  late final Widget? prefixIcon;
  late final Widget? suffixIcon;
  late final TextInputType? keyboardType;
  late final bool? enabled;
  late final int? minLines;
  late final int? maxLines;
  late final AutovalidateMode? autovalidateMode;
  List<TextInputFormatter>? inputFormatters;

  CTextField({
    required this.controller,
    this.initialValue,
    required this.label,
    this.helperText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.enabled,
    this.minLines,
    this.maxLines,
    this.autovalidateMode,
    this.inputFormatters,
  }) {
    if (initialValue != null) {
      controller.text = initialValue!;
    }
  }

  @override
  _CTextFieldState createState() {
    return _CTextFieldState();
  }
}

class _CTextFieldState extends State<CTextField> {
  var hasFocus = false;

  final fieldKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    widget.controller.focusNode.addListener(() {
      setState(() {
        hasFocus = widget.controller.focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsetsDirectional.only(top: 7),
          child: TextFormField(
            key: fieldKey,
            enabled: widget.enabled,
            controller: widget.controller,
            autovalidateMode: widget.autovalidateMode,
            focusNode: widget.controller.focusNode,
            keyboardType: widget.keyboardType,
            validator: (value) {
              // this was raising a stubborn error, fixed by this https://stackoverflow.com/a/59478165
              var result = widget.controller.validate(value);
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                setState(() {});
              });
              return result;
            },
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            inputFormatters: widget.inputFormatters,
            decoration: InputDecoration(
                isDense: true,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                // we handle floating labels using our custom method below
                labelText: widget.label,
                helperText: widget.helperText,
                hintText: widget.hintText,
                helperMaxLines: 2,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: blue4,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: indicatorRed,
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: grey3,
                  ),
                ),
                prefixIcon:
                    // There seems to be a problem with TextField and custom SVGs sizing so I had to size down manually
                    widget.prefixIcon != null
                        ? Transform.scale(scale: 0.5, child: widget.prefixIcon)
                        : null,
                suffixIcon: widget.suffixIcon != null
                    ? Transform.scale(
                        scale: 0.5,
                        child: fieldKey.currentState?.mounted == true &&
                                fieldKey.currentState?.hasError == true
                            ? CAssetImage(
                                path: ImagePaths.error, color: indicatorRed)
                            : widget.suffixIcon)
                    : null),
          ),
        ),
        Container(
          margin: const EdgeInsetsDirectional.only(start: 11),
          padding: EdgeInsets.symmetric(horizontal: hasFocus ? 2 : 0),
          color: white,
          child: !hasFocus && widget.controller.value.text.isEmpty
              ? Container()
              : CText(
                  widget.label,
                  style: CTextStyle(
                      fontSize: 12,
                      lineHeight: 12,
                      color: fieldKey.currentState?.mounted == true &&
                              fieldKey.currentState?.hasError == true
                          ? indicatorRed
                          : blue4),
                ),
        ),
      ],
    );
  }
}

/// Extends TextEditingController to provide the ability to set custom errors as
/// when forms are validated.
class CustomTextEditingController extends TextEditingController {
  final FocusNode focusNode = FocusNode();
  final GlobalKey<FormState> formKey;
  final FormFieldValidator<String>? validator;
  String? _error;

  CustomTextEditingController(
      {String? text, required this.formKey, this.validator})
      : super(text: text);

  String? validate(String? value) {
    if (_error != null) {
      final result = _error;
      _error = null;
      return result;
    }

    if (validator == null) {
      return null;
    }
    return validator!(value);
  }

  /// Sets custom error and forces form validation to make error show up.
  set error(String? error) {
    _error = error;
    formKey.currentState?.validate();
  }
}
