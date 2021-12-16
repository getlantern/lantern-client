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
  final showWarning = true;

  @override
  void initState() {
    super.initState();
    var dy =
        defaultWarningBarHeight; // initializing this to 30.0 for now, will be fine-tuned in next lines
    Future.delayed(Duration.zero, () {
      var screenInfo = MediaQuery.of(context);
      dy = screenInfo.viewInsets.top + screenInfo.padding.top;
    });

    controller =
        AnimationController(duration: shortAnimationDuration, vsync: this)
          ..addListener(() => setState(() {}));
    animation = Tween(
            begin: showWarning
                ? hasSeenAnimation
                    ? dy
                    : 0.0
                : 0.0,
            end: showWarning ? dy : 0.0)
        .animate(controller);
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return testRTL(
      Scaffold(
        backgroundColor: widget.backgroundColor,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        appBar: !widget.showAppBar
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(appBarHeight),
                child: Transform.translate(
                  offset: Offset(0.0, animation.value),
                  child: Stack(
                    fit: StackFit.loose,
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
                          dy: animation.value, showWarning: showWarning),
                    ],
                  ),
                ),
              ),
        body: Padding(
          padding: EdgeInsetsDirectional.only(
            start: widget.padHorizontal ? 16 : 0,
            end: widget.padHorizontal ? 16 : 0,
            top: widget.padVertical ? 16 + animation.value : animation.value,
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
    required this.showWarning,
  }) : super(key: key);

  final double dy;
  final bool showWarning;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: yellow6,
      height: dy,
      child: GestureDetector(
        onTap: isNetworkError()
            ? null
            : () => showInfoDialog(
                  context,
                  title: 'connection_error'.i18n,
                  des: 'connection_error_des'.i18n,
                  buttonText: 'connection_error_button'.i18n,
                  showCancel: true,
                ),
        child: CText(
          (isNetworkError() ? 'no_network_connection' : 'connection_error')
              .i18n
              .toUpperCase(),
          style: tsBody2.copiedWith(
              color: white,
              lineHeight:
                  24), // TODO: hardcoding this isn't great, but I'm having a hard time centering the text vertically otherwise
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // returns true if this is a network error
  bool isNetworkError() {
    return false;
  }
}
