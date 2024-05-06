import 'package:lantern/common/common.dart';

/// This a custom TextField that renders a label in its outline, aligned with
/// the prefix icon. We don't use the default behavior of OutlineInputBorder
/// because it aligns the label to the right of the prefix icon, in
/// contravention of the Material design specification.
class CTextField extends StatefulWidget {
  late final CustomTextEditingController controller;
  late final String? initialValue;
  late final dynamic? label;
  late final String? helperText;
  late final String? hintText;
  late final Widget? prefixIcon;
  late final Widget? suffixIcon;
  late final TextInputType? keyboardType;
  late final bool? enabled;
  late final int? minLines;
  late final int? maxLines;
  late final AutovalidateMode? autovalidateMode;
  late final List<TextInputFormatter>? inputFormatters;
  late final TextInputAction? textInputAction;
  late final void Function(String value)? onFieldSubmitted;
  late final String? actionIconPath;
  late final FloatingLabelBehavior? floatingLabelBehavior;
  late final int? maxLength;
  late final InputCounterWidgetBuilder? buildCounter;
  late final TextCapitalization? textCapitalization;
  late final EdgeInsetsDirectional? contentPadding;
  late final TextStyle? style;
  late final void Function()? onTap;
  late final bool removeCounterText;
  late final bool removeBorder;
  late final bool? autofocus;
  late final void Function(String value)? onChanged;
  String? tooltipMessage;

  CTextField({
    required this.controller,
    this.initialValue,
    this.label,
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
    this.textInputAction,
    this.onFieldSubmitted,
    this.actionIconPath,
    this.floatingLabelBehavior,
    this.maxLength,
    this.buildCounter,
    this.textCapitalization,
    this.contentPadding,
    this.style,
    this.onTap,
    this.removeCounterText = true,
    this.removeBorder = false,
    this.autofocus = false,
    this.onChanged,
    this.tooltipMessage,
  }) {
    if (initialValue != null && initialValue != '') {
      controller.text = initialValue!;
      // add a small delay to lifecycle error which results from this component being wrapped in the subscribedSingleValueBuilder() call that returns the initial value
      Future.delayed(defaultTransitionDuration, () {
        controller.text = initialValue!;
      });
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
  final scrollController = ScrollController();

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
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const noBorder = OutlineInputBorder(
      borderSide: BorderSide(
        width: 0,
        style: BorderStyle.none,
      ),
    );
    return Stack(
      children: [
        Container(
          padding: const EdgeInsetsDirectional.only(top: 7),
          child: Scrollbar(
            controller: scrollController,
            interactive: true,
            // TODO: this generates an annoying error https://github.com/flutter/flutter/issues/97873
            // thumbVisibility: true,
            trackVisibility: true,
            child: Tooltip(
              message: isDesktop() ? '' : (widget.tooltipMessage ?? ''),
              child: TextFormField(
                key: fieldKey,
                autofocus: widget.autofocus!,
                enabled: widget.enabled,
                controller: widget.controller,
                scrollPhysics: defaultScrollPhysics,
                autovalidateMode: widget.autovalidateMode,
                focusNode: widget.controller.focusNode,
                keyboardType: widget.keyboardType,
                maxLength: widget.maxLength,
                validator: (value) {
                  // this was raising a stubborn error, fixed by this https://stackoverflow.com/a/59478165
                  var result = widget.controller.validate(value);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {});
                  });
                  return result;
                },
                onTap: widget.onTap,
                onChanged: (value) {
                  if (widget.onChanged != null) {
                    widget.onChanged!(value);
                  }
                  fieldKey.currentState!.validate();
                },
                onFieldSubmitted: widget.onFieldSubmitted,
                textInputAction: widget.textInputAction,
                minLines: widget.minLines,
                maxLines: widget.maxLines,
                style: widget.style,
                inputFormatters: widget.inputFormatters,
                textCapitalization:
                    widget.textCapitalization ?? TextCapitalization.none,
                decoration: InputDecoration(
                  contentPadding: widget.contentPadding ??
                      (isDesktop()
                          ? const EdgeInsetsDirectional.only(
                              top: 24,
                              bottom: 24,
                            )
                          : const EdgeInsetsDirectional.only(
                              top: 8,
                              bottom: 8,
                            )),
                  isDense: true,
                  floatingLabelBehavior: widget.floatingLabelBehavior ?? FloatingLabelBehavior.never,
                  // we handle floating labels using our custom method below
                  labelText: (widget.label is String) ? widget.label : '',
                  helperText: widget.helperText,
                  hintText: widget.hintText,
                  helperMaxLines: 2,
                  focusedBorder: !widget.removeBorder
                      ? OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: blue4,
                          ),
                        )
                      : noBorder,
                  errorBorder: !widget.removeBorder
                      ? OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: indicatorRed,
                          ),
                        )
                      : noBorder,
                  border: !widget.removeBorder
                      ? OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: grey3,
                          ),
                        )
                      : noBorder,
                  prefixIcon:
                      // There seems to be a problem with TextField and custom SVGs sizing so I had to size down manually
                      widget.prefixIcon != null
                          ? Transform.scale(
                              scale: 0.5, child: widget.prefixIcon)
                          : null,
                  suffixIcon: renderSuffixRow(),
                  // forcibly remove if removeBorder == true
                  // otherwise, it will show up if we have a maxLength set
                  counterText: (widget.removeCounterText || widget.removeBorder)
                      ? ''
                      : null,
                ),
              ),
            ),
          ),
        ),
        // * Label
        if (widget.label != null)
          (widget.label is String)
              ? Container(
                  margin: const EdgeInsetsDirectional.only(start: 11),
                  padding: EdgeInsetsDirectional.only(
                    start: hasFocus ? 2 : 0,
                    end: hasFocus ? 2 : 0,
                  ),
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
                                : blue4,
                          ),
                        ),
                )
              : widget.label,
      ],
    );
  }

  Widget? renderSuffixRow() {
    final suffix = renderSuffix();
    final actionButton = renderActionButton();

    if (suffix == null) {
      return actionButton;
    } else if (actionButton == null) {
      return suffix;
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [suffix, actionButton],
      );
    }
  }

  Widget? renderSuffix() {
    final hasError = fieldKey.currentState?.mounted == true &&
        fieldKey.currentState?.hasError == true;
    final isEmpty = fieldKey.currentState?.mounted == true &&
        fieldKey.currentState?.value == '';
    if (isEmpty) return null;
    return hasError
        ? Transform.scale(
            scale: 0.4,
            child: CAssetImage(
              path: ImagePaths.error,
              color: indicatorRed,
            ),
          )
        : widget.suffixIcon != null
            ? Transform.scale(scale: 0.4, child: widget.suffixIcon)
            : null;
  }

  Widget? renderActionButton() {
    if (widget.actionIconPath == null) {
      return null;
    }

    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(blue4),
        elevation: MaterialStateProperty.all(0),
        fixedSize: MaterialStateProperty.all(const Size(56, 56)),
        shape: MaterialStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.only(
              topEnd: Radius.circular(4),
              bottomEnd: Radius.circular(4),
            ),
          ),
        ),
      ),
      onPressed: () {
        if (widget.onFieldSubmitted != null) {
          widget.onFieldSubmitted!(widget.controller.text);
        }
      },
      child: CAssetImage(
        key: const ValueKey('submit_text_field'),
        path: widget.actionIconPath!,
        color: white,
      ),
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
  String? initialValue;

  CustomTextEditingController({
    String? text,
    required this.formKey,
    this.validator,
  }) : super(text: text);

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

  set initialize(String? initialValue) {
    if (initialValue != null) {
      this.initialValue = initialValue;
    }
  }

  /// Sets custom error and forces form validation to make error show up.
  set error(String? error) {
    _error = error;
    formKey.currentState?.validate();
  }
}
