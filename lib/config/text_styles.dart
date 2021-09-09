import 'package:lantern/package_store.dart';

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

// Custom styles

TextStyle tsTitleAppbar =
    TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: black);

TextStyle tsCircleAvatarLetter =
    TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: white);

TextStyle tsStopWatchTimer = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: stopwatchColor,
);

TextStyle tsCountdownTimer = TextStyle(
  fontSize: 48,
  color: white,
);

TextStyle tsTitleItem =
    const TextStyle(fontWeight: FontWeight.w500, fontSize: 16);

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

TextStyle? tsInfoDialogText(color) => TextStyle(
      fontSize: 14,
      height: 23 / 14,
      color: color,
    );

TextStyle? tsInfoDialogButton = TextStyle(
  fontWeight: FontWeight.w600,
  fontSize: 14,
  color: primaryPink,
);

TextStyle txSnackBarText = const TextStyle(
  fontSize: 14,
  color: Colors.white,
  height: 23 / 14,
);

TextStyle tsInfoTextWhite = TextStyle(
  color: white,
);
TextStyle tsInfoTextBlack = TextStyle(
  color: black,
);

TextStyle tsInfoButton = tsInfoTextWhite.copyWith(fontWeight: FontWeight.w400);

TextStyle tsFullScreenDialogTitle = const TextStyle(
  fontSize: 20,
  color: Colors.white,
  fontWeight: FontWeight.w600,
);

// Message bubble StyleSheet
TextStyle? tsReplySnippetHeader = const TextStyle(
  fontWeight: FontWeight.w600,
  fontSize: 14,
  height: 23 / 14,
  color: Colors.black,
);

TextStyle? tsReplySnippetSpecialCase =
    const TextStyle(fontStyle: FontStyle.italic);
