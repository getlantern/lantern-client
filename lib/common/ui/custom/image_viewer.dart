import 'package:lantern/messaging/messaging.dart';

class CImageViewer extends ViewerWidget {
  final Future<Uint8List> loadImageFile;
  @override
  final Widget? title;
  @override
  final List<Widget>? actions;
  @override
  final Map<String, dynamic>? metadata;

  CImageViewer({
    required this.loadImageFile,
    this.title,
    this.actions,
    this.metadata,
  }) : super();

  @override
  State<StatefulWidget> createState() => CImageViewerState();
}

class CImageViewerState extends ViewerState<CImageViewer> {
  BasicMemoryImage? image;

  @override
  void initState() {
    super.initState();
    context.loaderOverlay.show(widget: spinner);
    widget.loadImageFile.catchError((e, stack) {
      logger.e('Error while loading image file: $e, $stack');
    }).then((bytes) {
      context.loaderOverlay.hide();
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
