import 'package:lantern/messaging/conversation/status_row.dart';
import 'package:lantern/messaging/messaging.dart';

/// Base class for widgets that allow viewing attachments like images and videos.
abstract class ViewerWidget extends StatefulWidget {
  final Contact contact;
  final StoredMessage message;

  ViewerWidget(this.contact, this.message);
}

/// Base class for state associated with ViewerWidgets.
abstract class ViewerState<T extends ViewerWidget> extends State<T> {
  bool showInfo = true;

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  bool ready();

  Widget body(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: CText(
        widget.contact.displayNameOrFallback,
        maxLines: 1,
        style: tsHeading3.copiedWith(color: white),
      ),
      padHorizontal: false,
      foregroundColor: white,
      backgroundColor: black,
      showAppBar: showInfo,
      body: GestureDetector(
        onTap: () => setState(() => showInfo = !showInfo),
        child: !showInfo && ready()
            ? Align(alignment: Alignment.center, child: body(context))
            : Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: !ready() ? Container() : body(context)),
                  Padding(
                      padding: const EdgeInsetsDirectional.all(4),
                      child: StatusRow(
                          widget.message.direction == MessageDirection.OUT,
                          widget.message)),
                ],
              ),
      ),
    );
  }

  void forceLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
  }
}
