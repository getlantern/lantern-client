import 'package:lantern/app.dart';
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
  late final Color backgroundColor;
  final bool automaticallyImplyLeading;

  BaseScreen({
    this.title,
    this.actions,
    required this.body,
    this.actionButton,
    this.floatingActionButtonLocation,
    this.centerTitle = true,
    this.resizeToAvoidBottomInset = true,
    this.padHorizontal = true,
    this.padVertical = false,
    Color? foregroundColor,
    Color? backgroundColor,
    this.showAppBar = true,
    this.automaticallyImplyLeading = true,
    Key? key,
  }) : super(key: key) {
    this.foregroundColor = foregroundColor ?? black;
    this.backgroundColor = backgroundColor ?? white;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: networkWarningBarHeightRatio,
      builder: (
        BuildContext context,
        double networkWarningBarHeightRatio,
        Widget? child,
      ) =>
          doBuild(context, networkWarningBarHeightRatio),
    );
  }

  Widget doBuild(BuildContext context, double networkWarningBarHeightRatio) {
    final screenInfo = MediaQuery.of(context);
    var verticalCorrection =
        (screenInfo.viewInsets.top + screenInfo.padding.top) *
            networkWarningBarHeightRatio;

    return testRTL(
      Scaffold(
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: !showAppBar
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(appBarHeight),
                child: Transform.translate(
                  offset: Offset(0.0, verticalCorrection),
                  child: Stack(
                    fit: StackFit.passthrough,
                    alignment: AlignmentDirectional.topCenter,
                    children: [
                      AppBar(
                        automaticallyImplyLeading: automaticallyImplyLeading,
                        title: title is String
                            ? CText(
                                title,
                                style: tsHeading3
                                    .copiedWith(color: foregroundColor)
                                    .short,
                              )
                            : title,
                        elevation: 1,
                        shadowColor: grey3,
                        foregroundColor: foregroundColor,
                        backgroundColor: backgroundColor,
                        iconTheme: IconThemeData(color: foregroundColor),
                        centerTitle: centerTitle,
                        titleSpacing: 0,
                        actions: actions,
                      ),
                      ConnectivityWarning(
                        dy: verticalCorrection,
                      ),
                    ],
                  ),
                ),
              ),
        body: Padding(
          padding: EdgeInsetsDirectional.only(
            start: padHorizontal ? 16 : 0,
            end: padHorizontal ? 16 : 0,
            top: padVertical ? 16 + verticalCorrection : verticalCorrection,
            bottom: padVertical ? 16 : 0,
          ),
          child: body,
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

class ConnectivityWarning extends StatelessWidget {
  const ConnectivityWarning({
    Key? key,
    required this.dy,
  }) : super(key: key);

  final double dy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !sessionModel.proxyAvailable.value
          ? () => CDialog(
                title: 'connection_error'.i18n,
                description: 'connection_error_des'.i18n,
                agreeText: 'connection_error_button'.i18n,
                agreeAction: () async {
                  LanternNavigator.startScreen(
                    LanternNavigator.SCREEN_SCREEN_REPORT_ISSUE,
                  );
                  return true;
                },
              ).show(context)
          : null,
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: yellow6,
        height: dy,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CText(
              (!sessionModel.proxyAvailable.value
                      ? 'connection_error'
                      : 'no_network_connection')
                  .i18n
                  .toUpperCase(),
              style: tsBody2.copiedWith(
                color: white,
              ),
              textAlign: TextAlign.center,
            ),
            if (!sessionModel.proxyAvailable.value)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 4.0, top: 3.0),
                child: CAssetImage(
                  path: ImagePaths.info,
                  size: 12,
                  color: white,
                ),
              )
          ],
        ),
      ),
    );
  }
}
