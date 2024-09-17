import 'package:lantern/core/utils/common.dart';

class PasswordCriteriaWidget extends StatefulWidget {
  final TextEditingController textEditingController;

  const PasswordCriteriaWidget({
    Key? key,
    required this.textEditingController,
  }) : super(key: key);

  @override
  _PasswordCriteriaWidgetState createState() => _PasswordCriteriaWidgetState();
}

class _PasswordCriteriaWidgetState extends State<PasswordCriteriaWidget> {
  bool has8Characters = false;
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;
  bool hasSpecialCharacter = false;

  @override
  void initState() {
    super.initState();
    widget.textEditingController.addListener(_updateCriteria);
  }

  @override
  void dispose() {
    widget.textEditingController.removeListener(_updateCriteria);
    super.dispose();
  }

  void _updateCriteria() {
    final text = widget.textEditingController.text;
    setState(() {
      has8Characters = text.length >= 8;
      hasUppercase = text.contains(RegExp(r'[A-Z]'));
      hasLowercase = text.contains(RegExp(r'[a-z]'));
      hasNumber = text.contains(RegExp(r'[0-9]'));
      hasSpecialCharacter = text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration:
          BoxDecoration(color: grey1, borderRadius: BorderRadius.circular(8.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CText('Password must contain at least:',
              style: tsBody2!.copiedWith(
                color: black,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              )),
          const SizedBox(height: 5),
          _buildCriteriaRow('8 or more characters', has8Characters),
          _buildCriteriaRow('1 UPPERCASE letter', hasUppercase),
          _buildCriteriaRow('1 lowercase letter', hasLowercase),
          _buildCriteriaRow('1 number', hasNumber),
          _buildCriteriaRow('1 special character', hasSpecialCharacter),
        ],
      ),
    );
  }

  Widget _buildCriteriaRow(String criteria, bool metCriteria) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            metCriteria ? Icons.check_circle : Icons.radio_button_unchecked,
            color: metCriteria ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          CText(criteria, style: tsBody2!.copiedWith(color: grey5)),
        ],
      ),
    );
  }
}
