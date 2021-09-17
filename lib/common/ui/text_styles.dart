import 'package:lantern/common/common.dart';

/*
******************
BASE STYLES
https://www.figma.com/file/Jz424KUVkFFc2NsxuYaZKL/Lantern-Component-Library?node-id=2%3A115
******************
*/

CTextStyle tsDisplay(color) => CTextStyle(
      fontSize: 48,
      lineHeight: 48,
      color: color,
    );

CTextStyle tsHeading1 =
    CTextStyle(fontSize: 24, minFontSize: 18, lineHeight: 39);

CTextStyle tsHeading2 = CTextStyle(
    fontSize: 20,
    minFontSize: 16,
    lineHeight: 32,
    fontWeight: FontWeight.w400,
    color: black);

CTextStyle tsSubtitle1 = CTextStyle(
    fontSize: 16, lineHeight: 26, fontWeight: FontWeight.w400, color: black);

CTextStyle tsSubtitle2 = CTextStyle(
    fontSize: 14, lineHeight: 23, fontWeight: FontWeight.w500, color: black);

CTextStyle tsBody = CTextStyle(color: black, fontSize: 14, lineHeight: 23);

CTextStyle tsBodyColor(color) => tsBody.copiedWith(color: color);

CTextStyle tsBody2 = CTextStyle(color: black, fontSize: 12, lineHeight: 19);

CTextStyle tsBody3 = CTextStyle(color: black, fontSize: 16, lineHeight: 23);

CTextStyle tsTextField =
    CTextStyle(fontSize: 16, lineHeight: 18.75, fontWeight: FontWeight.w400);

CTextStyle tsFloatingLabel =
    CTextStyle(fontSize: 12, lineHeight: 12, fontWeight: FontWeight.w400);

CTextStyle tsButton = CTextStyle(
  fontSize: 14,
  lineHeight: 14,
  fontWeight: FontWeight.w500,
);

CTextStyle tsOverline = CTextStyle(color: black, fontSize: 10, lineHeight: 16);

/*
******************
BUTTON VARIATIONS
******************
*/

CTextStyle tsButtonGrey = tsButton.copiedWith(color: grey5);

CTextStyle tsButtonPink = tsButton.copiedWith(color: pink4);

CTextStyle tsButtonWhite = tsButton.copiedWith(color: white);
