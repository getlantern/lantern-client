import 'package:lantern/common/common.dart';

/*
******************
BASE STYLES
******************
*/

CTextStyle tsAppbarTitle = CTextStyle(
    fontSize: 20,
    minFontSize: 14,
    lineHeight: 23,
    fontWeight: FontWeight.w500,
    color: black);

CTextStyle tsTitle = CTextStyle(
    fontSize: 16, lineHeight: 26, fontWeight: FontWeight.w500, color: black);

CTextStyle tsTitlePink = tsTitle.copiedWith(color: primaryPink);

CTextStyle tsBody10 = CTextStyle(color: black, fontSize: 10, lineHeight: 16);

CTextStyle tsBody13 = CTextStyle(color: black, fontSize: 13, lineHeight: 19);

CTextStyle tsBody13Bold = tsBody13.copiedWith(fontWeight: FontWeight.w500);

CTextStyle tsBody14 = CTextStyle(color: black, fontSize: 14, lineHeight: 23);

CTextStyle tsBody14Bold = tsBody14.copiedWith(fontWeight: FontWeight.w500);

CTextStyle tsBody16 = CTextStyle(color: black, fontSize: 16, lineHeight: 23);

CTextStyle tsBody16Bold = tsBody16.copiedWith(fontWeight: FontWeight.w500);

CTextStyle tsBottomBar =
    CTextStyle(fontSize: 12, lineHeight: 12, fontWeight: FontWeight.w400);

/*
******************
MESSAGING STYLES
******************
*/

CTextStyle tsCircleAvatarLetter =
    CTextStyle(fontSize: 14, lineHeight: 23, color: white);

CTextStyle tsDisappearingTimer =
    CTextStyle(fontSize: 10, lineHeight: 16, fontWeight: FontWeight.bold);

CTextStyle tsDisappearingContentBottomModal = CTextStyle(
    color: grey5, fontSize: 14.0, lineHeight: 21, fontWeight: FontWeight.w400);

CTextStyle tsStopWatchTimer = CTextStyle(
  fontSize: 10,
  lineHeight: 16,
  color: stopwatchColor,
);

CTextStyle tsCountdownTimer(color) => CTextStyle(
      fontSize: 48,
      lineHeight: 56.25,
      color: color,
    );

CTextStyle tsMessageBody(outbound) => CTextStyle(
    color: outbound ? outboundMsgColor : inboundMsgColor,
    fontSize: 16,
    lineHeight: 24);

CTextStyle tsMessageStatus(outbound) => CTextStyle(
      color: outbound ? outboundMsgColor : inboundMsgColor,
      fontSize: 10,
      lineHeight: 16,
    );

CTextStyle tsEmptyContactState = CTextStyle(
  color: black,
  fontSize: 16,
  lineHeight: 26,
);

CTextStyle txConversationSticker =
    CTextStyle(color: grey5, fontSize: 12, lineHeight: 19);

CTextStyle tsReplySnippetHeader = CTextStyle(
  fontWeight: FontWeight.w500,
  fontSize: 14,
  lineHeight: 23,
  color: black,
);

CTextStyle tsReplySnippet = CTextStyle(
  fontSize: 16,
  lineHeight: 26,
  color: black,
);

CTextStyle tsReplySnippetSpecialCase =
    tsReplySnippet.copiedWith(fontStyle: FontStyle.italic);

CTextStyle tsIntroductionsListHeader = CTextStyle(fontSize: 10, lineHeight: 16);

CTextStyle tsCallTitle =
    CTextStyle(fontSize: 22, minFontSize: 18, lineHeight: 26, color: white);

CTextStyle tsCallSubtitle =
    CTextStyle(color: white, fontSize: 14, lineHeight: 18);

/*
******************
DIALOGS AND MODALS
******************
*/

CTextStyle tsBottomModalListItem = CTextStyle(fontSize: 16, lineHeight: 18.75);

CTextStyle tsDialogTitle = CTextStyle(fontSize: 16, lineHeight: 26);

CTextStyle tsAlertDialogListTile = CTextStyle(
    fontSize: 14.0, lineHeight: 23, fontWeight: FontWeight.w400, color: black);

CTextStyle tsDialogBody = CTextStyle(fontSize: 14, lineHeight: 21);

CTextStyle tsInfoDialogSubtitle(color) => CTextStyle(
      fontSize: 16,
      lineHeight: 26,
      color: color,
      fontWeight: FontWeight.w400,
    );

CTextStyle tsInfoDialogText(color) => CTextStyle(
      fontSize: 14,
      lineHeight: 23,
      color: color,
      fontWeight: FontWeight.w400,
    );

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
