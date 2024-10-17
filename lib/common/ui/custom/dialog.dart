import 'dart:developer' as developer;

import 'package:flutter/gestures.dart';
import 'package:lantern/core/utils/common.dart';

/// CDialog incorporates the standard dialog styling and behavior as defined
/// in the [component library](https://www.figma.com/file/Jz424KUVkFFc2NsxuYaZKL/Lantern-Component-Library?node-id=27%3A28).
class CDialog extends StatefulWidget {
  /// logs the given exception+stacktrace and shows a standard error dialog.
  static void showError(
    BuildContext context, {
    required String description,
    Object? error,
    StackTrace? stackTrace,
    VoidCallback? okAction,
  }) {
    if (error != null || stackTrace != null) {
      developer.log(description, error: error, stackTrace: stackTrace);
    }
    CDialog(
      title: 'Error'.i18n,
      description: description,
      iconPath: ImagePaths.alert,
      barrierDismissible: false,
      agreeText: 'OK'.i18n,
      agreeAction: () async {
        okAction?.call();
        return true;
      },
      includeCancel: false,
    ).show(context);
  }

  static void noPurchaseFound(BuildContext context) {
    CDialog(
      title: 'purchase_not_found'.i18n,
      description: 'no_previous_purchase'.i18n,
      iconPath: ImagePaths.alert,
      barrierDismissible: false,
      agreeText: 'OK',
    ).show(context);
  }

  static void purchaseRestoredDialog(BuildContext context) {
    CDialog(
      title: ''.i18n,
      description: ''.i18n,
      iconPath: ImagePaths.check_green_large,
      barrierDismissible: false,
      agreeText: 'OK',
    ).show(context);
  }

  static void successDialog(
      {required BuildContext context,
      required String title,
      required String description,
      String? agreeText,
      VoidCallback? successCallback}) {
    CDialog(
      iconPath: ImagePaths.check_green_large,
      title: title,
      description: description,
      barrierDismissible: false,
      agreeText: agreeText ?? "continue".i18n,
      includeCancel: false,
      agreeAction: () async {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (successCallback != null) {
            successCallback.call();
            return true;
          }
        });
        return true;
      },
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
    bool barrierDismissible = true,
    bool autoCloseOnDismiss = true,
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
      barrierDismissible: barrierDismissible,
    ).show(context);
  }

  static void showInternetUnavailableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Center(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(bottom: 16),
                  child: CAssetImage(
                      path: ImagePaths.cloudOff, color: Colors.black),
                ),
              ),
              Center(
                  child: CText('check_your_internet_connection'.i18n,
                      style: tsSubtitle1)),
              const SizedBox(height: 10),
              CText('please_try'.i18n, style: tsSubtitle2),
              RichText(
                  text: TextSpan(
                children: [
                  TextSpan(text: '1.', style: tsSubtitle2),
                  const WidgetSpan(
                      child: SizedBox(
                    width: 5,
                  )),
                  TextSpan(
                      text: 'turning_off_airplane_mode'.i18n, style: tsBody1)
                ],
              )),
              RichText(
                  text: TextSpan(
                children: [
                  TextSpan(text: '2.', style: tsSubtitle2),
                  const WidgetSpan(
                      child: SizedBox(
                    width: 5,
                  )),
                  TextSpan(
                      text: 'turning_on_mobile_data_or_wifi'.i18n,
                      style: tsBody1)
                ],
              )),
              RichText(
                  text: TextSpan(
                children: [
                  TextSpan(text: '3.', style: tsSubtitle2),
                  const WidgetSpan(
                      child: SizedBox(
                    width: 5,
                  )),
                  TextSpan(
                      text: 'check_the_signal_in_your_area'.i18n,
                      style: tsBody1)
                ],
              )),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child:
                        CText('got_it'.i18n.toUpperCase(), style: tsButtonPink),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    // CDialog(
    //   icon: const CAssetImage(path: ImagePaths.cloudOff, color: Colors.grey),
    //   title: 'Check your internet connection'.i18n,
    //   agreeText: 'Got it',
    //   // crossAxisAlignment: CrossAxisAlignment.start,
    //   description: Column(
    //     // mainAxisSize: MainAxisSize.max,
    //     // crossAxisAlignment: CrossAxisAlignment.start,
    //     mainAxisAlignment: MainAxisAlignment.start,
    //     children: <Widget>[
    //       Container(
    //           color: Colors.amber,
    //           child: CText('Please try',
    //               style: tsBody1, textAlign: TextAlign.start)),
    //       RichText(
    //           text: TextSpan(children: [
    //         TextSpan(text: '1. ', style: tsBody1),
    //       ]))
    //     ],
    //   ),
    // ).show(context);
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
    this.autoCloseOnDismiss = true,
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
  final bool autoCloseOnDismiss;

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
        // crossAxisAlignment: hasIcon ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
                      if (widget.autoCloseOnDismiss) {
                        widget.close(context);
                      }
                    },
                    child: CText(
                      (widget.dismissText ?? 'cancel'.i18n).toUpperCase(),
                      style: tsButtonGrey,
                    ),
                  ),
                // AGREE
                Tooltip(
                  message: '',
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

void showEmailExistsDialog(
    {required BuildContext context, required VoidCallback recoverTap}) {
  CDialog(
    title: 'email_already_exists'.i18n,
    icon: const CAssetImage(
      path: ImagePaths.warning,
    ),
    agreeText: "recover_account".i18n,
    dismissText: "back".i18n,
    includeCancel: true,
    agreeAction: () async {
      recoverTap.call();
      return true;
    },
    dismissAction: () async {
      print("Go back");
    },
    description: "email_already_exists_msg".i18n,
  ).show(context);
}

void showProUserDialog(BuildContext context, {VoidCallback? onSuccess}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: const CAssetImage(
          path: ImagePaths.addAccountIllustration,
          height: 110,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CText(
              'update_pro_account'.i18n,
              textAlign: TextAlign.center,
              style: tsSubtitle1Short,
            ),
            const SizedBox(height: 16),
            CText(
              'update_pro_account_message'.i18n,
              style: tsBody1.copiedWith(
                color: grey5,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              width: double.infinity,
              child: Button(
                text: "update_account".i18n,
                onPressed: () {
                  if (onSuccess != null) {
                    onSuccess.call();
                    return;
                  }
                  context.maybePop();
                  context.pushRoute(SignIn(authFlow: AuthFlow.updateAccount));
                },
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                text: 'already_have_an_account'.i18n,
                style:
                    tsBody1.copyWith(fontWeight: FontWeight.w400, color: grey5),
                children: [
                  TextSpan(
                    text: "sign_in".i18n.toUpperCase(),
                    style: tsBody1.copyWith(
                        fontWeight: FontWeight.w500, color: pink5),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        context.maybePop();
                        context.pushRoute(SignIn(authFlow: AuthFlow.signIn));
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
