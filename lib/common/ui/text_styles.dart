import 'package:lantern/common/common.dart';

//
// This file will contain text styles (font weight, size, line height, color) for text that figures in reusable components such as Alert and Info Dialogs, Messages etc
//

// Global styles
CTextStyle tsSubHead(BuildContext context) => tsTitleHeadVPNItem;

CTextStyle tsSubTitle(BuildContext context) => tsSubTitleItem;

CTextStyle tsCaption(BuildContext context) => tsExplanation;

CTextStyle tsDisappearingTimer =
    CTextStyle(fontSize: 10, lineHeight: 16, fontWeight: FontWeight.bold);

CTextStyle tsTitleAppbar = CTextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 20,
    minFontSize: 14,
    lineHeight: 23,
    color: black);

// Custom styles
CTextStyle tsCircleAvatarLetter =
    CTextStyle(fontSize: 14, lineHeight: 23, color: white);

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

CTextStyle tsTitleItem =
    CTextStyle(fontWeight: FontWeight.w500, fontSize: 16, lineHeight: 26);

CTextStyle tsSubTitleItem = tsTitleItem.copiedWith(
    fontWeight: FontWeight.w400, fontSize: 12, lineHeight: 19);

CTextStyle tsSettingsItem = CTextStyle(fontSize: 16, lineHeight: 21);

CTextStyle tsSelectedTitleItem = tsTitleItem.copiedWith(color: primaryPink);

CTextStyle tsTitleHeadVPNItem = CTextStyle(
  fontSize: 14,
  lineHeight: 23,
);

CTextStyle tsTitleTrailVPNItem =
    tsTitleHeadVPNItem.copiedWith(fontWeight: FontWeight.w600);

CTextStyle tsPinLabel = CTextStyle(fontSize: 10, lineHeight: 16);

CTextStyle tsExplanation = CTextStyle(fontSize: 14, lineHeight: 23);

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

CTextStyle tsBaseScreenBodyText =
    CTextStyle(color: black, fontSize: 16, lineHeight: 23);

CTextStyle txConversationSticker =
    CTextStyle(color: grey5, fontSize: 12, lineHeight: 19);

// Dialogs
CTextStyle tsBottomModalTitle = CTextStyle(fontSize: 14, lineHeight: 23);

CTextStyle tsBottomModalList = CTextStyle(fontSize: 16, lineHeight: 18.75);

CTextStyle tsDialogTitle = CTextStyle(fontSize: 16, lineHeight: 26);

CTextStyle tsDisappearingContentBottomModal = CTextStyle(
    color: grey5, fontSize: 14.0, lineHeight: 21, fontWeight: FontWeight.w400);

CTextStyle tsAlertDialogListTile = CTextStyle(
    fontSize: 14.0, lineHeight: 23, fontWeight: FontWeight.w400, color: black);

CTextStyle tsDialogBody = CTextStyle(fontSize: 14, lineHeight: 21);

CTextStyle tsButtonGrey = CTextStyle(
  color: grey5,
  fontSize: 14,
  lineHeight: 14,
  fontWeight: FontWeight.w500,
);

CTextStyle tsButtonPink = tsButtonGrey.copiedWith(color: white);

CTextStyle tsInfoDialogSubtitle(color) => CTextStyle(
      fontSize: 16,
      lineHeight: 26,
      color: color,
      fontWeight: FontWeight.w400,
    );

// TODO: rename this since its used more widely than dialogs
CTextStyle tsInfoDialogText(color) => CTextStyle(
      fontSize: 14,
      lineHeight: 23,
      color: color,
      fontWeight: FontWeight.w400,
    );

CTextStyle tsInfoDialogButton = tsButtonPink;

CTextStyle tsFullScreenDialogTitle = CTextStyle(
  fontSize: 20,
  lineHeight: 24,
  color: white,
  fontWeight: FontWeight.w600,
);

CTextStyle tsFullScreenDialogTitleBlack =
    tsFullScreenDialogTitle.copiedWith(color: black);

// Message bubble StyleSheet
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

CTextStyle tsBottomBarLabel =
    CTextStyle(fontSize: 12, lineHeight: 12, fontWeight: FontWeight.w400);
