import 'package:lantern/common/common.dart';

/*
******************
BASE STYLES
******************
*/

CTextStyle tsHeading1 =
    CTextStyle(fontSize: 24, minFontSize: 18, lineHeight: 39);

CTextStyle tsHeading1White = tsHeading1.copiedWith(color: white);

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

CTextStyle tsBodyGrey = tsBody.copiedWith(color: grey5);

CTextStyle tsBodyPink = tsBody.copiedWith(color: primaryPink);

CTextStyle tsBody2 = CTextStyle(color: black, fontSize: 12, lineHeight: 19);

CTextStyle tsBody2White = tsBody2.copiedWith(color: white);

CTextStyle tsBody2Bold = tsBody2.copiedWith(fontWeight: FontWeight.w500);

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

CTextStyle tsButtonGrey = tsButton.copiedWith(color: grey5);

CTextStyle tsButtonPink = tsButton.copiedWith(color: primaryPink);

CTextStyle tsButtonWhite = tsButton.copiedWith(color: white);

CTextStyle tsInfoDialogButton = tsButtonPink;

CTextStyle tsOverline = CTextStyle(color: black, fontSize: 10, lineHeight: 16);

// cleanup

CTextStyle tsBody10 = CTextStyle(color: black, fontSize: 10, lineHeight: 16);

CTextStyle tsBody14 = CTextStyle(color: black, fontSize: 14, lineHeight: 23);

/*
******************
MESSAGING SPECIFIC
******************
*/

CTextStyle tsAppbarTitle = tsHeading2.copiedWith(fontWeight: FontWeight.w500);

CTextStyle tsCountdownTimer(color) => CTextStyle(
      fontSize: 48,
      lineHeight: 56.25,
      color: color,
    );

CTextStyle txConversationSticker =
    CTextStyle(color: grey5, fontSize: 12, lineHeight: 19);

CTextStyle tsCallSubtitle = tsBody.copiedWith(color: white);

/*
******************
DIALOGS AND MODALS
******************
*/

CTextStyle tsBottomModalListItem = CTextStyle(fontSize: 16, lineHeight: 18.75);

CTextStyle tsInfoDialogText(color) => tsBody.copiedWith(color: color);

CTextStyle tsFullScreenDialogTitle = CTextStyle(
  fontSize: 20,
  lineHeight: 24,
  color: white,
  fontWeight: FontWeight.w600,
);

CTextStyle tsFullScreenDialogTitleBlack =
    tsFullScreenDialogTitle.copiedWith(color: black);
