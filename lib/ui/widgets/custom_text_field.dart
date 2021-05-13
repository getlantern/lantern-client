import 'package:lantern/package_store.dart';

//// This a custom TextField that renders a label in its outline, aligned with
//// the prefix icon. We don't use the default behavior of OutlineInputBorder
//// because it aligns the label to the right of the prefix icon, in
//// contravention of the Material design specification.
class CustomTextField extends StatefulWidget {
  late final TextEditingController controller;
  late final String label;
  late final String? helperText;
  late final Icon? prefixIcon;

  CustomTextField(
      {required this.controller,
      required this.label,
      this.helperText,
      this.prefixIcon});

  @override
  _CustomTextFieldState createState() {
    return _CustomTextFieldState();
  }
}

class _CustomTextFieldState extends State<CustomTextField> {
  var hasFocus = false;

  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {
        hasFocus = focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsetsDirectional.only(top: 7),
          child: TextFormField(
            controller: widget.controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              // we handle floating labels using our custom method below
              labelText: widget.label,
              helperText: widget.helperText,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2,
                  color: HexColor(primaryBlue),
                ),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2,
                ),
              ),
              prefixIcon: widget.prefixIcon,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsetsDirectional.only(start: 11),
          padding: EdgeInsets.symmetric(horizontal: hasFocus ? 2 : 0),
          color: Colors.white,
          child: !hasFocus
              ? Container()
              : Text(
                  widget.label,
                  style: TextStyle(color: HexColor(primaryBlue)),
                ),
        ),
      ],
    );
  }
}
