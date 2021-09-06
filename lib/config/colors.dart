import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

Color primaryBlue = HexColor('#007A7C');
Color primaryPink = HexColor('#DB0A5B');
Color primaryYellow = HexColor('#FFC107');
Color secondaryBlue = HexColor('#00BCD4');
Color secondaryPink = HexColor('#FF4081');
Color secondaryYellow = HexColor('#FFE600');
Color countdownTimerColor = Colors.red.shade900;
Color white = HexColor('#FFFFFF');
Color black = HexColor('#000000');
Color grey1 = HexColor('#F9F9F9');
Color grey2 = HexColor('#F5F5F5');
Color grey3 = HexColor('#EBEBEB');
Color grey4 = HexColor('#BFBFBF');
Color grey5 = HexColor('#707070');
Color indicatorRed = HexColor('#D5001F');
Color indicatorGreen = HexColor('#00A83E');
Color overlayBlack = HexColor('#000000CB');

Color outboundBgColor = HexColor('#007A7C');
Color outboundMsgColor = HexColor('#FFFFFF');
Color inboundMsgColor = HexColor('#000000');
Color inboundBgColor = HexColor('#EBEBEB');
Color snippetBgColor = HexColor('#F5F5F5');
Color snippetShadowColor = const Color.fromARGB(
  100,
  0,
  0,
  0,
);
Color snippetBgIconColor = HexColor('#707070');

Color unselectedTabColor = grey1;
Color selectedTabColor = white;
Color unselectedTabLabelColor = grey5;
Color selectedTabLabelColor = black;
Color borderColor = grey3;
Color offSwitchColor = grey5;
Color onSwitchColor = secondaryBlue;
Color usedDataBarColor = primaryBlue;
Color circleAvatarTitle = const Color.fromRGBO(122, 0, 59, 1);
Color recordingColorBackground = const Color.fromRGBO(213, 0, 31, 1);

Color pulsingShadow = Colors.red.shade900;
Color pulsingBackground = Colors.red;

List<Color> avatarBgColors = [
  HexColor('#003B7A'),
  HexColor('#007A02'),
  HexColor('#0A5ADB'),
  HexColor('#7A003B'),
  HexColor('#7A0078'),
  HexColor('#8B4910'),
  HexColor('#957000')
];

Color getCheckboxColor(Set<MaterialState> states) {
  const interactiveStates = <MaterialState>{
    MaterialState.pressed,
    MaterialState.hovered,
    MaterialState.focused,
  };
  if (states.any(interactiveStates.contains)) {
    return Colors.white;
  }
  return Colors.black;
}
