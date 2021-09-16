import 'package:lantern/common/common.dart';

/*
******************
BASE STYLES
******************
*/

CTextStyle tsAppbarTitle = CTextStyle(
    fontSize: 20,
    minFontSize: 16,
    lineHeight: 23,
    fontWeight: FontWeight.w500,
    color: black);

CTextStyle tsTitle = CTextStyle(
    fontSize: 16, lineHeight: 26, fontWeight: FontWeight.w500, color: black);

CTextStyle tsTitlePink = tsTitle.copiedWith(color: primaryPink);

CTextStyle tsBody10 = CTextStyle(color: black, fontSize: 10, lineHeight: 16);

CTextStyle tsBody10Bold =
    CTextStyle(color: black, fontSize: 10, lineHeight: 16);

CTextStyle tsBody13 = CTextStyle(color: black, fontSize: 13, lineHeight: 19);

CTextStyle tsBody13White = tsBody13.copiedWith(color: white);

CTextStyle tsBody13Bold = tsBody13.copiedWith(fontWeight: FontWeight.w500);

CTextStyle tsBody14 = CTextStyle(color: black, fontSize: 14, lineHeight: 23);

CTextStyle tsBody14Grey = tsBody14.copiedWith(color: grey5);

CTextStyle tsBody14Bold = tsBody14.copiedWith(fontWeight: FontWeight.w500);

CTextStyle tsBody16 = CTextStyle(color: black, fontSize: 16, lineHeight: 23);

CTextStyle tsBody16Bold = tsBody16.copiedWith(fontWeight: FontWeight.w500);

CTextStyle tsBottomBar =
    CTextStyle(fontSize: 12, lineHeight: 12, fontWeight: FontWeight.w400);

/*
******************
MESSAGING SPECIFIC
******************
*/

CTextStyle tsCountdownTimer(color) => CTextStyle(
      fontSize: 48,
      lineHeight: 56.25,
      color: color,
    );

CTextStyle txConversationSticker =
    CTextStyle(color: grey5, fontSize: 12, lineHeight: 19);

CTextStyle tsCallTitle =
    CTextStyle(fontSize: 24, minFontSize: 18, lineHeight: 39, color: white);

CTextStyle tsCallSubtitle = tsBody14.copiedWith(color: white);

/*
******************
DIALOGS AND MODALS
******************
*/

CTextStyle tsBottomModalListItem = CTextStyle(fontSize: 16, lineHeight: 18.75);

CTextStyle tsInfoDialogText(color) => tsBody14.copiedWith(color: color);

CTextStyle tsFullScreenDialogTitle = CTextStyle(
  fontSize: 20,
  lineHeight: 24,
  color: white,
  fontWeight: FontWeight.w600,
);

CTextStyle tsFullScreenDialogTitleBlack =
    tsFullScreenDialogTitle.copiedWith(color: black);

/*
******************
BUTTONS
******************
*/

CTextStyle tsButtonGrey = CTextStyle(
  color: grey5,
  fontSize: 14,
  lineHeight: 14,
  fontWeight: FontWeight.w500,
);

CTextStyle tsButtonPink = tsButtonGrey.copiedWith(color: primaryPink);

CTextStyle tsButtonWhite = tsButtonGrey.copiedWith(color: white);

CTextStyle tsInfoDialogButton = tsButtonPink;
