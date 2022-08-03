import 'dart:developer' as developer;

import 'package:lantern/common/common.dart';

/// CDialog incorporates the standard dialog styling and behavior as defined
/// in the [component library](https://www.figma.com/file/Jz424KUVkFFc2NsxuYaZKL/Lantern-Component-Library?node-id=27%3A28)
/// dismissAction -> DISMISS button
/// maybeAgreeAction -> Checkbox-aware AGREE button
/// agreeAction -> AGREE button
class CDialog extends StatefulWidget {
  /// logs the given exception+stacktrace and shows a standard error dialog.
  static void showError(
    BuildContext context, {
    required String description,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (error != null || stackTrace != null) {
      developer.log(description, error: error, stackTrace: stackTrace);
    }
    CDialog(
      title: 'Error'.i18n,
      description: description,
      iconPath: ImagePaths.alert,
      barrierDismissible: false,
    ).show(context);
  }

  /// shows a standard informational dialog that has only one action ("OK").
  static void showInfo(
    BuildContext context, {
    String? iconPath,
    required String title,
    required String description,
  }) {
    CDialog(
      iconPath: iconPath,
      title: title,
      description: description,
    ).show(context);
  }

  CDialog({
    this.iconPath,
    this.iconSize,
    required this.title,
    required this.description,
    this.checkboxLabel,
    this.checkboxChecked = false,
    this.autoDismissAfter,
    this.barrierDismissible = true,
    this.dismissText,
    this.agreeText,
    this.agreeTextColor,
    this.agreeAction,
    this.maybeAgreeAction,
    this.dismissAction,
  }) : super();

  final String? iconPath;
  final double? iconSize;
  final String title;
  final dynamic description;
  final String? checkboxLabel;
  final bool checkboxChecked;
  final Duration? autoDismissAfter;
  final bool barrierDismissible;
  final String? dismissText;
  final String? agreeText;
  final CTextStyle? agreeTextColor;
  final Future<bool> Function()? agreeAction;
  final Future<bool> Function(bool confirmed)? maybeAgreeAction;
  final Future<void> Function(bool confirmed)? dismissAction;
  final closeOnce = once();

  void Function() show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => this,
    );
    return () => close(context);
  }

  void close(BuildContext context) {
    closeOnce(() {
      Navigator.pop(context);
    });
  }

  @override
  CDialogState createState() => CDialogState();
}

class CDialogState extends State<CDialog> {
  var checkboxChecked = false;
  Timer? autoDismissTimer;

  @override
  void initState() {
    super.initState();
    checkboxChecked = widget.checkboxChecked;

    if (widget.autoDismissAfter != null) {
      autoDismissTimer = Timer(widget.autoDismissAfter!, () {
        widget.dismissAction?.call(checkboxChecked);
      });
    }
  }

  @override
  void dispose() {
    autoDismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsetsDirectional.only(
        top: 24,
        bottom: 8,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: widget.iconPath != null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (widget.iconPath != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 16),
              child: CAssetImage(
                  path: widget.iconPath!,
                  size: widget.iconSize != null ? widget.iconSize! : 24),
            ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 24, end: 24),
            child: CText(
              widget.title,
              style: tsSubtitle1Short,
            ),
          ),
          Flexible(
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.only(start: 24, end: 24, top: 16),
              child: SingleChildScrollView(
                child: widget.description is Widget
                    ? widget.description
                    : CText(
                        widget.description as String,
                        style: tsBody1.copiedWith(
                          color: grey5,
                        ),
                      ),
              ),
            ),
          ),
          if (widget.checkboxLabel != null)
            CInkWell(
              onTap: () => setState(() => checkboxChecked = !checkboxChecked),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      visualDensity: VisualDensity.compact,
                      shape: const RoundedRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(2.0)),
                      ),
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(
                        (states) => getCheckboxFillColor(black, states),
                      ),
                      value: checkboxChecked,
                      onChanged: (bool? value) {
                        setState(() => checkboxChecked = value!);
                      },
                    ),
                    Expanded(
                      child: CText(
                        widget.checkboxLabel!,
                        style: tsBody1Short,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 24,
              end: 24,
              top: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // DISMISS
                if (widget.agreeAction != null ||
                    widget.maybeAgreeAction != null)
                  TextButton(
                    onPressed: () async {
                      if (widget.dismissAction != null) {
                        await widget.dismissAction!(checkboxChecked);
                      }
                      widget.close(context);
                    },
                    child: CText(
                      (widget.dismissText ?? 'cancel'.i18n).toUpperCase(),
                      style: tsButtonGrey,
                    ),
                  ),
                // AGREE
                TextButton(
                  onPressed: () async {
                    if (widget.maybeAgreeAction != null) {
                      if (await widget.maybeAgreeAction!(checkboxChecked)) {
                        widget.close(context);
                      }
                    } else if (widget.agreeAction != null) {
                      if ((widget.checkboxLabel == null || checkboxChecked) &&
                          await widget.agreeAction!()) {
                        widget.close(context);
                      }
                    } else {
                      widget.close(context);
                    }
                  },
                  child: CText(
                    (widget.agreeText ?? 'OK'.i18n).toUpperCase(),
                    style: widget.checkboxLabel == null || checkboxChecked
                        ? tsButtonPink
                        : widget.agreeTextColor != null
                        ? widget.agreeTextColor!
                        : tsButtonGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
