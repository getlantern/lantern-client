import 'package:lantern/common/common.dart';

//
// This file will contain text styles (font weight, size, line height, color) for text that figures in reusable components such as Alert and Info Dialogs, Messages etc
//

// Global styles
TextStyle? tsSubHead(BuildContext context) =>
    Theme.of(context).textTheme.subtitle1;

TextStyle? tsSubTitle(BuildContext context) =>
    Theme.of(context).textTheme.subtitle2;

TextStyle? tsCaption(BuildContext context) =>
    Theme.of(context).textTheme.caption;

TextStyle tsDisappearingTimer =
    const TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold);

TextStyle tsDisappearingTimerDetail =
    const TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold);

CustomTextStyle tsTitleAppbar = CustomTextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 20,
    minFontSize: 14,
    fontHeight: 23,
    color: black);

// Custom styles
TextStyle tsCircleAvatarLetter =
    TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: white);

TextStyle tsStopWatchTimer = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: stopwatchColor,
);

TextStyle tsCountdownTimer(color) => TextStyle(
      fontSize: 48,
      height: 56.25 / 48,
      color: color,
    );

CustomTextStyle tsTitleItem =
    CustomTextStyle(fontWeight: FontWeight.w500, fontSize: 16, fontHeight: 26);

TextStyle tsSettingsItem =
    const TextStyle(fontWeight: FontWeight.w400, fontSize: 16);

TextStyle tsSelectedTitleItem = tsTitleItem.copyWith(color: primaryPink);

TextStyle tsTitleHeadVPNItem =
    const TextStyle(fontWeight: FontWeight.w400, fontSize: 14);

TextStyle tsTitleTrailVPNItem =
    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14);

TextStyle tsPinLabel = const TextStyle(fontSize: 10);

TextStyle tsExplanation = const TextStyle(height: 1.6);

TextStyle tsMessageBody(outbound) => TextStyle(
    color: outbound ? outboundMsgColor : inboundMsgColor,
    fontSize: 16,
    height: 24 / 16);

TextStyle tsMessageStatus(outbound) => TextStyle(
      color: outbound ? outboundMsgColor : inboundMsgColor,
      fontSize: 10,
    );

TextStyle tsEmptyContactState = const TextStyle(
  color: Colors.black,
  fontSize: 16,
  height: 26 / 16,
);

TextStyle tsBaseScreenBodyText =
    const TextStyle(color: Colors.black, fontSize: 16, height: 23 / 16);

TextStyle txConversationSticker =
    TextStyle(color: grey5, fontSize: 12, height: 19 / 12);

// Dialogs
TextStyle tsBottomModalTitle =
    const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

TextStyle tsBottomModalList = const TextStyle(fontSize: 16, height: 18.75 / 16);

TextStyle tsDialogTitle = const TextStyle(fontSize: 16);

TextStyle tsDisappearingContentBottomModal = TextStyle(
    color: grey5, fontSize: 14.0, height: 1.5, fontWeight: FontWeight.w400);

TextStyle tsAlertDialogListTile = const TextStyle(
    fontSize: 14.0, fontWeight: FontWeight.w400, color: Colors.black);

TextStyle tsDialogBody = const TextStyle(fontSize: 14, height: 1.5);

TextStyle tsDialogButtonGrey = TextStyle(
  color: grey5,
  fontSize: 14,
  fontWeight: FontWeight.w600,
);

TextStyle tsDialogButtonPink = TextStyle(
  color: primaryPink,
  fontSize: 14,
  fontWeight: FontWeight.w600,
);

TextStyle tsInfoDialogSubtitle(color) => TextStyle(
      fontSize: 16,
      height: 26 / 16,
      color: color,
      fontWeight: FontWeight.w400,
    );

// TODO: rename this since its used more widely than dialogs
TextStyle tsInfoDialogText(color) => TextStyle(
      fontSize: 14,
      height: 23 / 14,
      color: color,
      fontWeight: FontWeight.w400,
    );

TextStyle tsInfoDialogButton = TextStyle(
  fontWeight: FontWeight.w600,
  fontSize: 14,
  color: primaryPink,
);

TextStyle tsFullScreenDialogTitle = const TextStyle(
  fontSize: 20,
  color: Colors.white,
  fontWeight: FontWeight.w600,
);

// Message bubble StyleSheet
TextStyle tsReplySnippetHeader = const TextStyle(
  fontWeight: FontWeight.w600,
  fontSize: 14,
  height: 23 / 14,
  color: Colors.black,
);

TextStyle tsReplySnippetSpecialCase =
    const TextStyle(fontStyle: FontStyle.italic);
