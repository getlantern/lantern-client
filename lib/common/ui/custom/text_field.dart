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
  late final Icon? prefixIcon;
  late final Icon? suffixIcon;
  late final TextInputType? keyboardType;
  late final bool? enabled;
  late final int? minLines;
  late final int? maxLines;
  late final AutovalidateMode? autovalidateMode;

  CTextField({
    required this.controller,
    this.initialValue,
    required this.label,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.enabled,
    this.minLines,
    this.maxLines,
    this.autovalidateMode,
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
              var result = widget.controller.validate(value);
              setState(() {});
              return result;
            },
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                // we handle floating labels using our custom method below
                labelText: widget.label,
                helperText: widget.helperText,
                helperMaxLines: 2,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: primaryBlue,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: red,
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: grey3,
                  ),
                ),
                prefixIcon: widget.prefixIcon,
                suffixIcon: fieldKey.currentState?.mounted == true &&
                        fieldKey.currentState?.hasError == true
                    ? Icon(Icons.error, color: red)
                    : widget.suffixIcon),
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
                          ? red
                          : primaryBlue),
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
