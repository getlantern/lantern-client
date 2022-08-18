import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';
import 'package:lantern/replica/ui/viewers/layout.dart';

/// Renders an embedded image preview with fullscreen option
/// wrapped by our reusable ReplicaViewer layout
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
    return GestureDetector(
      // * Thumbnail
      child: renderImageThumbnail(
        imageUrl: thumbnailURL,
        item: widget.item,
        size: 100,
      ),
      // * Trigger FullScreenImageViewer() on tap
      onTap: () async => await launchFullScreen(context),
    );
  }

  Future launchFullScreen(BuildContext context) async {
    return await context.router.push(
      FullScreenDialogPage(
        widget: FullScreenImageViewer(
          loadImageFile: widget.replicaApi.getImageBytesFromURL(
            imageURL,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CText(
                widget.item.replicaLink.displayName ?? 'untitled'.i18n,
                style: tsHeading3.copiedWith(color: white),
              ),
              CText(
                SearchCategory.Image.toShortString(),
                style: tsOverline.copiedWith(color: white),
              )
            ],
          ),
          actions: [
            IconButton(
              onPressed: () async => handleDownload(
                context,
                widget.item,
                widget.replicaApi,
              ),
              icon: CAssetImage(
                size: 20,
                path: ImagePaths.file_download,
                color: white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
