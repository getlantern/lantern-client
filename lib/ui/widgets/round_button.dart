import 'package:lantern/package_store.dart';

//// A round button
class RoundButton extends StatelessWidget {
  final Widget icon;
  final double diameter;
  final Color backgroundColor;
  final Color splashColor;
  final void Function() onPressed;

  RoundButton(
      {required this.icon,
      this.diameter = 56,
      required this.backgroundColor,
      this.splashColor = Colors.white,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size(diameter, diameter), // button width and height
      child: ClipOval(
        child: Material(
          color: backgroundColor, // button color
          child: InkWell(
            splashColor: splashColor,
            onTap: onPressed, // button pressed
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                icon,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
