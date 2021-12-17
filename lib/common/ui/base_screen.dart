import 'package:lantern/common/common.dart';

var forceRTL = false; // set to true to force RTL for testing

class BaseScreen extends StatefulWidget {
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
      Color? backgroundColor,
      this.showAppBar = true,
      this.automaticallyImplyLeading = true,
      Key? key})
      : super(key: key) {
    this.foregroundColor = foregroundColor ?? black;
    this.backgroundColor = backgroundColor ?? white;
  }

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> with TickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;
  final hasSeenAnimation = true;

  var dy = defaultWarningBarHeight;
  var serverError = false;
  var networkError = false;

  @override
  void initState() {
    super.initState();
    var eventType = sessionModel.connectivityNotifier().value;
    // * Connectivity event stream
    switch (eventType) {
      case Event.NetworkError:
        setState(() {
          networkError = true;
        });
        break;
      case Event.ServerError:
        setState(() {
          serverError = true;
        });
        break;
      default:
        break;
    }

    // * Animation
    var dy =
        defaultWarningBarHeight; // initializing this to 30.0 for now, will be fine-tuned in next lines

    // * Animation // initializing this to 30.0 for now, will be fine-tuned in next lines
    WidgetsBinding.instance?.addPostFrameCallback((_) => () {
          var screenInfo = MediaQuery.of(context);
          setState(() {
            dy = screenInfo.viewInsets.top + screenInfo.padding.top;
          });
        });

    controller =
        AnimationController(duration: shortAnimationDuration, vsync: this)
          ..addListener(() => setState(() {}));
    animation =
        Tween(begin: hasSeenAnimation ? dy : 0.0, end: dy).animate(controller);
    if (!hasSeenAnimation) controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var verticalCorrection =
        serverError || networkError ? animation.value : 0.0;

    return testRTL(
      Scaffold(
        backgroundColor: widget.backgroundColor,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        appBar: !widget.showAppBar
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
                        automaticallyImplyLeading:
                            widget.automaticallyImplyLeading,
                        title: widget.title is String
                            ? CText(
                                widget.title,
                                style: tsHeading3
                                    .copiedWith(color: widget.foregroundColor)
                                    .short,
                              )
                            : widget.title,
                        elevation: 1,
                        shadowColor: grey3,
                        foregroundColor: widget.foregroundColor,
                        backgroundColor: widget.backgroundColor,
                        iconTheme: IconThemeData(color: widget.foregroundColor),
                        centerTitle: widget.centerTitle,
                        titleSpacing: 0,
                        actions: widget.actions,
                      ),
                      ConnectivityWarning(
                        dy: verticalCorrection,
                        networkError: networkError,
                        serverError: serverError,
                      ),
                    ],
                  ),
                ),
              ),
        body: Padding(
          padding: EdgeInsetsDirectional.only(
            start: widget.padHorizontal ? 16 : 0,
            end: widget.padHorizontal ? 16 : 0,
            top: widget.padVertical
                ? 16 + verticalCorrection
                : verticalCorrection,
            bottom: widget.padVertical ? 16 : 0,
          ),
          child: widget.body,
        ),
        floatingActionButton: widget.actionButton,
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
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
    required this.networkError,
    required this.serverError,
  }) : super(key: key);

  final double dy;
  final bool networkError;
  final bool serverError;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: serverError
          ? () => showInfoDialog(context,
              title: 'connection_error'.i18n,
              des: 'connection_error_des'.i18n,
              buttonText: 'connection_error_button'.i18n,
              showCancel: true,
              buttonAction: () => context.router.push(Settings()))
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
              (serverError ? 'connection_error' : 'no_network_connection')
                  .i18n
                  .toUpperCase(),
              style: tsBody2.copiedWith(
                color: white,
              ),
              textAlign: TextAlign.center,
            ),
            if (serverError)
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
