import 'package:flutter/material.dart';
import 'package:lantern/common/ui/colors.dart';
import 'package:lantern/common/ui/custom/text.dart';
import 'package:lantern/common/ui/text_styles.dart';
import 'package:lantern/i18n/i18n.dart';

class ReplicaUploadDisclaimerAlertDialog extends StatefulWidget {
  ReplicaUploadDisclaimerAlertDialog(
      {Key? key, required this.onCancelPressed, required this.onResumePressed});
  final void Function(bool) onResumePressed;
  final void Function() onCancelPressed;
  @override
  _ReplicaUploadDisclaimerAlertDialogState createState() =>
      _ReplicaUploadDisclaimerAlertDialogState();
}

class _ReplicaUploadDisclaimerAlertDialogState
    extends State<ReplicaUploadDisclaimerAlertDialog> {
  bool fileUploadAlertDialogValue = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      title: const Text('Important!'),
      content: FractionallySizedBox(
        widthFactor: 0.8,
        heightFactor: 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CText(
              '''Files uploaded to the Lantern Network are publicly accessible. They are decentralized and cannot be deleted from the network by anyone.

Avoid personally identifying information in the file content and filename when uploading sensitive content.'''
                  .i18n,
              style: tsBody1.copiedWith(color: grey5),
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: fileUploadAlertDialogValue,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null) {
                          fileUploadAlertDialogValue = value;
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: CText(
                      "Don't show me this again",
                      style: tsBody1,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  TextButton(
                    onPressed: widget.onCancelPressed,
                    child: CText(
                      'Cancel'.i18n,
                      style: tsButton,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      widget.onResumePressed(fileUploadAlertDialogValue);
                    },
                    child: CText(
                      'Resume Upload'.i18n,
                      style: tsButton.copiedWith(color: pink4),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
