import 'package:lantern/messaging/messaging.dart';

class FullScreenImageViewer extends FullScreenViewer {
  final Future<Uint8List> loadImageFile;
  @override
  final Widget? title;
  @override
  final List<Widget>? actions;
  @override
  final Map<String, dynamic>? metadata;

  FullScreenImageViewer({
    required this.loadImageFile,
    this.title,
    this.actions,
    this.metadata,
  }) : super();

  @override
  State<StatefulWidget> createState() => FullScreenImageViewerState();
}

class FullScreenImageViewerState
    extends FullScreenViewerState<FullScreenImageViewer> {
  BasicMemoryImage? image;

  @override
  void initState() {
    super.initState();
    widget.loadImageFile.catchError((e, stack) {
      logger.e('Error while loading image file: $e, $stack');
    }).then((bytes) {
      BasicMemoryImage? newImage = BasicMemoryImage(bytes);
      setState(() => image = newImage);
    });
  }

  @override
  bool ready() => image != null;

  @override
  Widget body(BuildContext context) => Align(
        alignment: Alignment.center,
        child: InteractiveViewer(
          child: image!,
        ),
      );
}
