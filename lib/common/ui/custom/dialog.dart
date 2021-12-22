import 'package:lantern/common/common.dart';

/// CDialog incorporates the standard dialog styling and behavior as defined
/// in the [component library](https://www.figma.com/file/Jz424KUVkFFc2NsxuYaZKL/Lantern-Component-Library?node-id=27%3A28).
class CDialog extends StatefulWidget {
  CDialog({
    this.iconPath,
    required this.title,
    required this.explanation,
    this.checkboxLabel,
    this.checkboxChecked = false,
    required this.agreeText,
    this.dismissText,
    this.agreeAction,
    this.dismissAction,
    this.barrierDismissible = true,
    this.autoDismissAfter,
  }) : super();

  final String? iconPath;
  final String title;
  final dynamic explanation;
  final String? checkboxLabel;
  final bool checkboxChecked;
  final String agreeText;
  final String? dismissText;
  final Future<bool> Function(bool?)? agreeAction;
  final Future<void> Function()? dismissAction;
  final bool barrierDismissible;
  final Duration? autoDismissAfter;
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
    return AlertDialog(
      contentPadding: const EdgeInsetsDirectional.only(
        start: 24,
        top: 24,
        end: 24,
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
              child: CAssetImage(path: widget.iconPath!, size: 24),
            ),
          CText(
            widget.title,
            style: tsSubtitle1Short,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(top: 16),
              child: SingleChildScrollView(
                child: widget.explanation is Widget
                    ? widget.explanation
                    : CText(
                        widget.explanation as String,
                        style: tsBody1.copiedWith(
                          color: grey5,
                        ),
                      ),
              ),
            ),
          ),
          if (widget.checkboxLabel != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 16),
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
          Padding(
            padding: const EdgeInsetsDirectional.only(
              top: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // DISMISS
                TextButton(
                  onPressed: () async {
                    if (widget.dismissAction != null) {
                      await widget.dismissAction!();
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
                    if (widget.agreeAction != null) {
                      if (await widget.agreeAction!(checkboxChecked)) {
                        widget.close(context);
                      }
                    } else {
                      widget.close(context);
                    }
                  },
                  child: CText(
                    widget.agreeText.toUpperCase(),
                    style: tsButtonPink,
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
