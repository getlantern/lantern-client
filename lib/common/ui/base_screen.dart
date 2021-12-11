import 'package:lantern/common/common.dart';

var forceRTL = false; // set to true to force RTL for testing

class BaseScreen extends StatelessWidget {
  final dynamic title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? actionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? centerTitle;
  final bool resizeToAvoidBottomInset;
  final bool padHorizontal;
  final bool padVertical;
  final bool showAppBar;
  late final Color foregroundColor;
  late final Color appbarBackgroundColor;
  // Color of the body's background before padding
  late final Color bodyBackgroundColor;

  BaseScreen(
      {this.title,
      this.actions,
      required this.body,
      this.actionButton,
      this.floatingActionButtonLocation,
      this.centerTitle = true,
      this.resizeToAvoidBottomInset = true,
      this.padHorizontal = true,
      this.padVertical = false,
      Color? foregroundColor,
      Color? appbarBackgroundColor,
      Color? bodyBackgroundColor,
      this.showAppBar = true,
      Key? key})
      : super(key: key) {
    this.foregroundColor = foregroundColor ?? black;
    this.appbarBackgroundColor = appbarBackgroundColor ?? white;
    this.bodyBackgroundColor =
        bodyBackgroundColor ?? this.appbarBackgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    return testRTL(
      Scaffold(
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: !showAppBar
            ? null
            : AppBar(
                title: title is String
                    ? CText(
                        title,
                        style: tsHeading3.copiedWith(color: foregroundColor),
                      )
                    : title,
                elevation: 1,
                foregroundColor: foregroundColor,
                backgroundColor: appbarBackgroundColor,
                iconTheme: IconThemeData(color: foregroundColor),
                centerTitle: centerTitle,
                titleSpacing: 0,
                actions: actions,
              ),
        body: Container(
          color: bodyBackgroundColor,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: padHorizontal ? 16 : 0,
                vertical: padVertical ? 16 : 0),
            child: body,
          ),
        ),
        floatingActionButton: actionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      ),
    );
  }

  Widget testRTL(Widget child) {
    return !forceRTL
        ? child
        : Directionality(
            textDirection: TextDirection.rtl,
            child: child,
          );
  }
}
