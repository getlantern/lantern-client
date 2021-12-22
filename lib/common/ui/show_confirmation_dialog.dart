import 'package:lantern/common/common.dart';

void Function() showConfirmationDialog({
  required BuildContext context,
  Key? key,
  String? iconPath,
  required String title,
  required dynamic explanation,
  String? checkboxLabel,
  bool checkboxChecked = false,
  required String agreeText,
  String? dismissText,
  required Future<bool> Function(bool?) agreeAction,
  Future<void> Function()? dismissAction,
  bool barrierDismissible = true,
  Duration? autoDismissAfter,
}) {
  Timer? autoDismissTimer;
  var closed = false;

  void close() {
    autoDismissTimer?.cancel();
    if (!closed) {
      Navigator.pop(context);
      closed = true;
    }
  }

  if (autoDismissAfter != null) {
    autoDismissTimer = Timer(autoDismissAfter, () {
      dismissAction?.call();
    });
  }

  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          key: key,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: iconPath != null
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (iconPath != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 16),
                  child: CAssetImage(path: iconPath, size: 24),
                ),
              CText(
                title,
                style: tsSubtitle1,
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(top: 16),
                  child: SingleChildScrollView(
                    child: explanation is Widget
                        ? explanation
                        : CText(
                            explanation as String,
                            style: tsBody1.copiedWith(
                              color: grey5,
                            ),
                          ),
                  ),
                ),
              ),
              if (checkboxLabel != null)
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
                          checkboxLabel,
                          style: tsBody1,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            // DISMISS
            TextButton(
              onPressed: () async {
                if (dismissAction != null) {
                  await dismissAction();
                }
                close();
              },
              child: CText(
                (dismissText ?? 'cancel'.i18n).toUpperCase(),
                style: tsButtonGrey,
              ),
            ),
            // AGREE
            TextButton(
              onPressed: () async {
                if (await agreeAction(checkboxChecked)) {
                  close();
                }
              },
              child: CText(
                agreeText.toUpperCase(),
                style: tsButtonPink,
              ),
            ),
          ],
        ),
      );
    },
  );

  return close;
}
