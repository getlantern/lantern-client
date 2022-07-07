import 'package:lantern/common/common.dart';

// From https://stackoverflow.com/a/71633921
class CTextInputFormatter extends TextInputFormatter {
  final String separator;
  final int cutoff;

  CTextInputFormatter({
    Key? key,
    required this.separator,
    required this.cutoff,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue previousValue,
    TextEditingValue nextValue,
  ) {
    var inputText = nextValue.text;

    if (nextValue.selection.baseOffset == 0) {
      return nextValue;
    }

    var bufferString = StringBuffer();
    for (var i = 0; i < inputText.length; i++) {
      bufferString.write(inputText[i]);
      var nonZeroIndexValue = i + 1;
      if (nonZeroIndexValue % cutoff == 0 &&
          nonZeroIndexValue != inputText.length) {
        bufferString.write(separator);
      }
    }

    var string = bufferString.toString();
    return nextValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(
        offset: string.length,
      ),
    );
  }
}
