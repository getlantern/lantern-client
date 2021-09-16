import 'dart:ui';

import 'package:lantern/common/common.dart';
import 'package:hexcolor/hexcolor.dart';

Color transparent = Colors.transparent;
Color primaryBlue = HexColor('#007A7C');
Color primaryPink = HexColor('#DB0A5B');
Color primaryYellow = HexColor('#FFC107');
Color secondaryBlue = HexColor('#00BCD4');
Color secondaryPink = HexColor('#FF4081');
Color secondaryYellow = HexColor('#FFE600');

Color white = HexColor('#FFFFFF');
Color black = HexColor('#000000');
Color green = HexColor('#00A83E');
Color red = HexColor('#D5001F');
Color grey1 = HexColor('#F9F9F9');
Color grey2 = HexColor('#F5F5F5');
Color grey3 = HexColor('#EBEBEB');
Color grey4 = HexColor('#BFBFBF');
Color grey5 = HexColor('#707070');
Color overlayBlack = HexColor('#000000CB');

Color outboundBgColor = primaryBlue;
Color outboundMsgColor = white;
Color inboundMsgColor = black;
Color inboundBgColor = grey3;
Color snippetBgColor = grey2;
Color snippetShadowColor = const Color.fromARGB(100, 0, 0, 0);
Color unselectedTabColor = grey1;
Color selectedTabColor = white;
Color unselectedTabLabelColor = grey5;
Color selectedTabLabelColor = black;
Color borderColor = grey3;
Color offSwitchColor = grey5;
Color onSwitchColor = secondaryBlue;
Color usedDataBarColor = primaryBlue;

Color getCheckboxColor(Set<MaterialState> states) {
  const interactiveStates = <MaterialState>{
    MaterialState.pressed,
    MaterialState.hovered,
    MaterialState.focused,
  };
  return states.any(interactiveStates.contains) ? white : black;
}

// not using inverted right now but can be useful for eventually building color inversion
List<Color> avatarBgColors = [
  HexColor('#003B7A'),
  HexColor('#007A02'),
  HexColor('#0A5ADB'),
  HexColor('#7A003B'),
  HexColor('#7A0078'),
  HexColor('#8B4910'),
  HexColor('#957000')
];

Color getAvatarColor({required double hue, bool inverted = false}) =>
    HSLColor.fromAHSL(1, hue, 1, 0.3).toColor();
