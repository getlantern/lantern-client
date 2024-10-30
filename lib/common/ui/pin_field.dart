import 'package:lantern/core/utils/common.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

//// A field for entering PIN codes
class PinField extends StatelessWidget {
  late final int length;
  late final TextEditingController controller;
  late final TextInputType keyboardType;
  late final void Function(String text)? onDone;

  PinField({
    required this.length,
    required this.controller,
    this.keyboardType = TextInputType.phone,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => getClipboardData(context),
      child: PinCodeTextField(
        maxLength: length,
        keyboardType: keyboardType,
        controller: controller,
        onDone: (text) {
          if (onDone != null) {
            onDone!(text);
          }
        },

        autofocus: true,
        highlight: true,
        highlightColor: blue4,
        defaultBorderColor: grey4,
        hasTextBorderColor: grey4,
        onTextChanged: (text) {},
        pinBoxWidth: 44,
        pinBoxHeight: 64,
        wrapAlignment: WrapAlignment.spaceAround,
        textDirection: Directionality.of(context),
        pinBoxBorderWidth: 2,
        pinBoxRadius: 4,
        pinBoxDecoration: ProvidedPinBoxDecoration.defaultPinBoxDecoration,
        pinTextStyle: const TextStyle(fontSize: 40),
        pinTextAnimatedSwitcherTransition:
            ProvidedPinBoxTextAnimation.scalingTransition,
        pinTextAnimatedSwitcherDuration: const Duration(milliseconds: 300),
        highlightAnimationBeginColor: Colors.black,
        highlightAnimationEndColor: Colors.white12,
      ),
    );
  }

  Future<void> getClipboardData(BuildContext context) async {
    final copiedData = await Clipboard.getData('text/plain');
    if (copiedData?.text != null) {
      final code = copiedData!.text;
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: CText('Paste from clipboard?'.i18n, style: tsBody1),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: CText(
                  'No'.i18n,
                  style: tsButtonGrey,
                ),
              ),
              TextButton(
                onPressed: () {
                  controller.text = code!;
                  Navigator.pop(context);
                  onDone?.call(controller.text);
                },
                child: CText(
                  'Yes'.i18n,
                  style: tsButtonPink,
                ),
              ),
            ],
          );
        },
      );
    }
  }
}
