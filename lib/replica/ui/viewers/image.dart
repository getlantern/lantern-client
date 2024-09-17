import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';
import 'package:lantern/replica/ui/viewers/layout.dart';

/// Renders an embedded image preview with fullscreen option
/// wrapped by our reusable ReplicaViewer layout
@RoutePage(name: 'ReplicaImageViewer')
class ReplicaImageViewer extends ReplicaViewerLayout {
  ReplicaImageViewer({
    required ReplicaApi replicaApi,
    required ReplicaSearchItem item,
    required SearchCategory category,
  }) : super(replicaApi: replicaApi, item: item, category: category);

  @override
  State<StatefulWidget> createState() => _ReplicaImageViewerState();
}

class _ReplicaImageViewerState extends ReplicaViewerLayoutState {
  var thumbnailURL = '';
  var imageURL = '';

  @override
  void initState() {
    super.initState();
    thumbnailURL = widget.replicaApi.getThumbnailAddr(widget.item.replicaLink);
    imageURL = widget.replicaApi.getDownloadAddr(widget.item.replicaLink);
  }

  @override
  bool ready() => thumbnailURL.isNotEmpty && imageURL.isNotEmpty;

  @override
  Widget body(BuildContext context) {
    return Flexible(
      flex: 2,
      child: GestureDetector(
        // * Thumbnail
        child: renderImageThumbnail(
          imageUrl: thumbnailURL,
          item: widget.item,
        ),
        // * Trigger FullScreenImageViewer() on tap
        onTap: () async => await launchFullScreen(context),
      ),
    );
  }

  Future launchFullScreen(BuildContext context) async {
    return await context.router.push(
      FullScreenDialogPage(
        widget: LayoutBuilder(
          builder: ((context, constraints) => Container(
                decoration: BoxDecoration(
                  color: black,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth,
                      child: renderImageThumbnail(
                        imageUrl: thumbnailURL,
                        item: widget.item,
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
