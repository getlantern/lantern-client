import 'package:lantern/package_store.dart';

///TextTheme
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

TextStyle? tsTitleAppbar() => GoogleFonts.roboto().copyWith(
    fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xff040505));

TextStyle? tsTitleItem() =>
    GoogleFonts.roboto().copyWith(fontWeight: FontWeight.w500, fontSize: 16);

TextStyle? tsSelectedTitleItem() => tsTitleItem()?.copyWith(color: primaryPink);

TextStyle? tsTitleHeadVPNItem() =>
    GoogleFonts.roboto().copyWith(fontWeight: FontWeight.w400, fontSize: 14);

TextStyle? tsTitleTrailVPNItem() =>
    GoogleFonts.roboto().copyWith(fontWeight: FontWeight.w600, fontSize: 14);
