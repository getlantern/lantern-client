import 'package:lantern/features/messaging/messaging.dart';

/// Base class for widgets that allow viewing files like images and videos, for both Chat and Replica.
abstract class FullScreenViewer extends StatefulWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Map<String, dynamic>? metadata;

  FullScreenViewer({
    this.title,
    this.actions,
    this.metadata,
  });
}

/// Base class for state associated with FullScreenViewers. It is extended by CVideoViewer and CImageViewer, which in turn get extended by the respective Chat and Replica image/video rendering widgets. It handles orientation changes and compensates for a known Flutter bug in video orientation: https://github.com/flutter/flutter/issues/60327
abstract class FullScreenViewerState<T extends FullScreenViewer>
    extends State<T> with WidgetsBindingObserver {
  bool showInfo = true;
  Orientation orientation = Orientation.portrait;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // reset orientation
    orientation = Orientation.portrait;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  // didChangeMetrics(): Called when the application's dimensions change. For example, when a phone is rotated.
  @override
  void didChangeMetrics() {
    orientation = MediaQuery.of(context).orientation;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        orientation = MediaQuery.of(context).orientation;
      });
    });
  }

  bool ready();

  Widget body(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: widget.title,
      actions: widget.actions,
      padHorizontal: false,
      // we can keep this as is since the designs between Chat and Replica have been consolidated to have black background and white font color
      foregroundColor: white,
      backgroundColor: black,
      showAppBar: showInfo,
      body: GestureDetector(
        onTap: () => setState(() => showInfo = !showInfo),
        child: showInfo
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: body(context)),
                  widget.metadata?['ts'] ?? Container(),
                ],
              )
            : body(context),
      ),
    );
  }
}
