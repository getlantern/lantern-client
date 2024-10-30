import 'package:lantern/features/messaging/messaging.dart';

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
  var hasError = false;

  @override
  void initState() {
    super.initState();
    try {
      widget.loadImageFile.then((bytes) {
        BasicMemoryImage? newImage = BasicMemoryImage(bytes);
        setState(() => image = newImage);
      });
    } on TimeoutException {
      setState(() {
        hasError = true;
      });
    } catch (e, stack) {
      logger.e('Error while loading image file: $e, $stack');
      setState(() {
        hasError = true;
      });
    }
  }

  @override
  bool ready() => image != null && !hasError;

  @override
  Widget body(BuildContext context) => Align(
        alignment: Alignment.center,
        child: ready()
            ? InteractiveViewer(
                child: image!,
              )
            : Align(
                alignment: Alignment.center,
                child: CAssetImage(
                  path: ImagePaths.error,
                  size: 100,
                  color: white,
                ),
              ),
      );
}
