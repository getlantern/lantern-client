import 'package:lantern/package_store.dart';

// Global styles
TextStyle? tsHeadline1(BuildContext context) =>
    Theme.of(context).textTheme.headline1;

TextStyle? tsHeadline2(BuildContext context) =>
    Theme.of(context).textTheme.headline2;

TextStyle? tsHeadline3(BuildContext context) =>
    Theme.of(context).textTheme.headline3;

TextStyle? tsHeadline4(BuildContext context) =>
    Theme.of(context).textTheme.headline4;

TextStyle? tsHeadline5(BuildContext context) =>
    Theme.of(context).textTheme.headline5;

TextStyle? tsHeadline6(BuildContext context) =>
    Theme.of(context).textTheme.headline6;

TextStyle? tsSubHead(BuildContext context) =>
    Theme.of(context).textTheme.subtitle1;

TextStyle? tsSubTitle(BuildContext context) =>
    Theme.of(context).textTheme.subtitle2;

TextStyle? tsBody1(BuildContext context) =>
    Theme.of(context).textTheme.bodyText1;

TextStyle? tsBody2(BuildContext context) =>
    Theme.of(context).textTheme.bodyText2;

TextStyle? tsButton(BuildContext context) => Theme.of(context).textTheme.button;

TextStyle? tsCaption(BuildContext context) =>
    Theme.of(context).textTheme.caption;

TextStyle? tsOverline(BuildContext context) =>
    Theme.of(context).textTheme.overline;

// Custom styles

TextStyle? tsTitleAppbar() => GoogleFonts.roboto().copyWith(
    fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xff040505));

TextStyle? tsTitleItem() =>
    GoogleFonts.roboto().copyWith(fontWeight: FontWeight.w500, fontSize: 16);

TextStyle? tsSelectedTitleItem() => tsTitleItem()?.copyWith(color: primaryPink);

TextStyle? tsTitleHeadVPNItem() =>
    GoogleFonts.roboto().copyWith(fontWeight: FontWeight.w400, fontSize: 14);

TextStyle? tsTitleTrailVPNItem() =>
    GoogleFonts.roboto().copyWith(fontWeight: FontWeight.w600, fontSize: 14);

TextStyle? tsPinLabel() => const TextStyle(fontSize: 10);

TextStyle? tsExplanation() => const TextStyle(height: 1.6);

TextStyle? tsMessageBody(outbound) => TextStyle(
    color: outbound ? outboundMsgColor : inboundMsgColor, height: 1.3);

TextStyle? tsMessageStatus(outbound) => TextStyle(
      color: outbound ? outboundMsgColor : inboundMsgColor,
      fontSize: 10,
    );

// Dialogs
TextStyle? tsAlertDialogTitle() => GoogleFonts.roboto().copyWith(fontSize: 16);

TextStyle? tsAlertDialogBody() => const TextStyle(fontSize: 14, height: 1.5);

TextStyle? tsAlertDialogButton(color) => TextStyle(
      color: color,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

TextStyle? tsInfoDialogTitle() => GoogleFonts.roboto().copyWith(fontSize: 16);

TextStyle? tsInfoDialogText(color) => GoogleFonts.roboto().copyWith(
      fontSize: 14,
      height: 23 / 14,
      color: color,
    );

TextStyle? tsInfoDialogButton(color) => GoogleFonts.roboto().copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: color,
    );
