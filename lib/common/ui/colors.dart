import 'dart:ui';

import 'package:lantern/common/common.dart';
import 'package:hexcolor/hexcolor.dart';

Color transparent = Colors.transparent;

Color blue4 = HexColor('#007A7C');
Color pink4 = HexColor('#DB0A5B');
Color yellow4 = HexColor('#FFC107');

Color blue3 = HexColor('#00BCD4');
Color pink3 = HexColor('#FF4081');
Color yellow3 = HexColor('#FFE600');

// Grey scale
Color white = HexColor('#FFFFFF');
Color grey1 = HexColor('#F9F9F9');
Color grey2 = HexColor('#F5F5F5');
Color grey3 = HexColor('#EBEBEB');
Color grey4 = HexColor('#BFBFBF');
Color grey5 = HexColor('#707070');
Color scrimGrey = HexColor('#C4C4C4');
Color black = HexColor('#000000');

// Avatars
Color getAvatarColor({required double hue, bool inverted = false}) =>
    HSLColor.fromAHSL(1, hue, 1, 0.3).toColor();

// Indicator
Color indicatorGreen = HexColor('#00A83E');
Color indicatorRed = HexColor('#D5001F');

// Overlay
Color overlayBlack = HexColor('#000000CB');

// Checkbox color helper
Color getCheckboxColor(Set<MaterialState> states) {
  const interactiveStates = <MaterialState>{
    MaterialState.pressed,
    MaterialState.hovered,
    MaterialState.focused,
  };
  return states.any(interactiveStates.contains) ? white : black;
}

/*
******************
REUSABLE COLORS
******************
*/

Color outboundBgColor = blue4;
Color outboundMsgColor = white;

Color inboundMsgColor = black;
Color inboundBgColor = grey3;

Color snippetBgColor = grey2;
Color snippetShadowColor = const Color.fromARGB(100, 0, 0, 0);

Color selectedTabColor = white;
Color unselectedTabColor = grey1;

Color selectedTabLabelColor = black;
Color unselectedTabLabelColor = grey5;

Color borderColor = grey3;

Color onSwitchColor = blue3;
Color offSwitchColor = grey5;
Color usedDataBarColor = blue4;
