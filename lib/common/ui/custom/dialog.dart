import 'dart:developer' as developer;

import 'package:lantern/common/common.dart';

/// CDialog incorporates the standard dialog styling and behavior as defined
/// in the [component library](https://www.figma.com/file/Jz424KUVkFFc2NsxuYaZKL/Lantern-Component-Library?node-id=27%3A28).
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
    CAssetImage? icon,
    double? size,
    required String title,
    required String description,
    String? actionLabel,
    Future<bool> Function()? agreeAction,
    Future<bool> Function()? dismissAction,
  }) {
    CDialog(
      iconPath: iconPath,
      icon: icon,
      size: size,
      title: title,
      includeCancel: false,
      description: description,
      agreeAction: agreeAction,
      dismissAction: dismissAction,
    ).show(context);
  }

  CDialog({
    this.iconPath,
    this.icon,
    this.size,
    required this.title,
    required this.description,
    this.checkboxLabel,
    this.checkboxChecked = false,
    this.autoDismissAfter,
    this.barrierDismissible = true,
    this.dismissText,
    this.agreeText,
    this.agreeAction,
    this.maybeAgreeAction,
    this.dismissAction,
    this.includeCancel = true,
  }) : super();

  final String? iconPath;
  final CAssetImage? icon;
  final double? size;
  final String title;
  final dynamic description;
  final String? checkboxLabel;
  final bool checkboxChecked;
  final Duration? autoDismissAfter;
  final bool barrierDismissible;
  final String? dismissText;
  final String? agreeText;
  final Future<bool> Function()? agreeAction;
  final Future<bool> Function(bool confirmed)? maybeAgreeAction;
  final Future<void> Function()? dismissAction;
  final closeOnce = once();
  final bool includeCancel;

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
      // See https://dart.dev/tools/linter-rules/use_build_context_synchronously
      if (!context.mounted) return;
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
        widget.dismissAction?.call();
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
    var hasIcon = widget.icon != null || widget.iconPath != null;
    return AlertDialog(
      contentPadding: const EdgeInsetsDirectional.only(
        top: 24,
        bottom: 8,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            hasIcon ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (hasIcon)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 16),
              child: widget.icon != null
                  ? widget.icon!
                  : CAssetImage(path: widget.iconPath!, size: 24),
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
                if ((widget.agreeAction != null ||
                        widget.maybeAgreeAction != null) &&
                    widget.includeCancel)
                  TextButton(
                    onPressed: () async {
                      if (widget.dismissAction != null) {
                        await widget.dismissAction!();
                      }
                      // See https://dart.dev/tools/linter-rules/use_build_context_synchronously
                      if (!context.mounted) return;
                      widget.close(context);
                    },
                    child: CText(
                      (widget.dismissText ?? 'cancel'.i18n).toUpperCase(),
                      style: tsButtonGrey,
                    ),
                  ),
                // AGREE
                Tooltip(
                  message: AppKeys.renewalSuccessOk,
                  child: TextButton(
                    onPressed: () async {
                      if (widget.maybeAgreeAction != null) {
                        if (await widget.maybeAgreeAction!(checkboxChecked)) {
                          // See https://dart.dev/tools/linter-rules/use_build_context_synchronously
                          if (!context.mounted) return;
                          widget.close(context);
                        }
                      } else if (widget.agreeAction != null) {
                        if ((widget.checkboxLabel == null || checkboxChecked) &&
                            await widget.agreeAction!()) {
                          // See https://dart.dev/tools/linter-rules/use_build_context_synchronously
                          if (!context.mounted) return;
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
                          : tsButtonGrey,
                    ),
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
