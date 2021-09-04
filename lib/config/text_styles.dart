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
    TextStyle(fontSize: 8.0.sp, fontWeight: FontWeight.bold);

TextStyle tsDisappearingTimerDetail =
    TextStyle(fontSize: 8.0.sp, fontWeight: FontWeight.bold);

// Custom styles

TextStyle tsTitleAppbar =
    TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: black);

TextStyle tsCircleAvatarLetter =
    TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: white);

TextStyle tsCountdownTimer = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: countdownTimerColor,
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
TextStyle tsAlertDialogTitle = const TextStyle(fontSize: 16);

TextStyle tsAlertDialogBody = const TextStyle(fontSize: 14, height: 1.5);

TextStyle tsAlertDialogButtonGrey = TextStyle(
  color: grey4,
  fontSize: 14,
  fontWeight: FontWeight.w600,
);

TextStyle tsAlertDialogButtonPink = TextStyle(
  color: primaryPink,
  fontSize: 14,
  fontWeight: FontWeight.w600,
);

TextStyle? tsInfoDialogTitle = const TextStyle(fontSize: 16);

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

// Message bubble StyleSheet
TextStyle? tsReplySnippetHeader = const TextStyle(
  fontWeight: FontWeight.w600,
  fontSize: 14,
  height: 23 / 14,
  color: Colors.black,
);

TextStyle? tsReplySnippetSpecialCase =
    const TextStyle(fontStyle: FontStyle.italic);
