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
  final List<Widget>? persistentFooterButtons;

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
    this.persistentFooterButtons,
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
            ((sessionModel.hasAccountVerified.value == false &&
                    sessionModel.hasUserSignedInNotifier.value == true &&
                    sessionModel.proUserNotifier.value == true)
                ? 1
                : networkWarningBarHeightRatio);

    return testRTL(
      Scaffold(
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        persistentFooterButtons: persistentFooterButtons,
        appBar: !showAppBar
            ? null
            : PreferredSize(
                preferredSize:
                    Size.fromHeight(appBarHeight + verticalCorrection),
                child: SafeArea(
                  child: Column(
                    children: [
                      ConnectivityWarning(
                        dy: verticalCorrection,
                      ),
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
                        elevation: .5,
                        shadowColor: grey3,
                        foregroundColor: foregroundColor,
                        backgroundColor: backgroundColor,
                        iconTheme: IconThemeData(color: foregroundColor),
                        centerTitle: centerTitle,
                        titleSpacing: 0,
                        actions: actions,
                      ),
                    ],
                  ),
                ),
              ),
        body: Padding(
          padding: EdgeInsetsDirectional.only(
            start: padHorizontal ? 16 : 0,
            end: padHorizontal ? 16 : 0,
            top: padVertical ? 16 : 0,
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
      onTap: () => _onWarrningTap(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        width: MediaQuery.of(context).size.width,
        color: yellow6,
        height: dy,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (sessionModel.hasAccountVerified.value != true)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 10),
                child: CAssetImage(
                  path: ImagePaths.info,
                  color: white,
                ),
              ),
            CText(
              (sessionModel.proxyAvailable.value != true
                      ? 'connection_error'
                      : (sessionModel.hasAccountVerified.value == false &&
                              sessionModel.proUserNotifier.value == true)
                          ? 'confirm_email_error'.i18n
                          : 'no_network_connection')
                  .i18n
                  .toUpperCase(),
              style: tsBody2.copiedWith(
                color: white,
              ),
              textAlign: TextAlign.center,
            ),
            if (sessionModel.proxyAvailable.value != true)
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

  void _onWarrningTap(BuildContext context) {
    if (sessionModel.proxyAvailable.value != true) {
      CDialog(
        title: 'connection_error'.i18n,
        description: 'connection_error_des'.i18n,
        agreeText: 'connection_error_button'.i18n,
        agreeAction: () async {
          context.popRoute();
          await context.pushRoute(ReportIssue());
          return true;
        },
      ).show(context);
    }

    if (sessionModel.hasAccountVerified.value != true) {
      // User has completed the signin process
      // User does not have account verified
      // Before sending user to screen send OTP again
      final email = sessionModel.userEmail.value.validateEmail;
      if (email.isEmpty) return;
      sessionModel.signUpEmailResendCode(email);
      context.pushRoute(
          Verification(email: email, authFlow: AuthFlow.verifyEmail));
      return;
    }
  }
}
