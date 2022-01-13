import 'package:lantern/messaging/conversation/status_row.dart';
import 'package:lantern/messaging/messaging.dart';

/// Base class for widgets that allow viewing attachments like images and videos.
abstract class ViewerWidget extends StatefulWidget {
  final ReplicaViewerProps? replicaProps;
  final MessagingViewerProps? messagingProps;
  final Widget? title;
  final List<Widget>? actions;

  ViewerWidget(
    this.replicaProps,
    this.messagingProps,
    this.title,
    this.actions,
  );
}

/// Base class for state associated with ViewerWidgets.
abstract class ViewerState<T extends ViewerWidget> extends State<T>
    with WidgetsBindingObserver {
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
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
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
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
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
      foregroundColor: white,
      backgroundColor: black,
      showAppBar: showInfo,
      body: GestureDetector(
        onTap: () => setState(() => showInfo = !showInfo),
        child: !showInfo && ready()
            ? Align(alignment: Alignment.center, child: body(context))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: !ready() ? Container() : body(context)),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8, top: 8),
                    child: widget.messagingProps != null
                        ? StatusRow(
                            widget.messagingProps!.message.direction ==
                                MessageDirection.OUT,
                            widget.messagingProps!.message,
                          )
                        : null,
                  ),
                ],
              ),
      ),
    );
  }
}
