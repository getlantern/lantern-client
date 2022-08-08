import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

/// ReplicaImagePreviewScreen renders a Replica image in the middle of its view
///
/// This screen supports landscape and portrait orientations
// TODO <08-08-22, kalli> Update to reflect Figma
class ReplicaImagePreviewScreen extends StatefulWidget {
  ReplicaImagePreviewScreen({Key? key, required this.replicaLink});

  final ReplicaLink replicaLink;

  @override
  State<ReplicaImagePreviewScreen> createState() =>
      _ReplicaImagePreviewScreenState();
}

class _ReplicaImagePreviewScreenState extends State<ReplicaImagePreviewScreen> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return replicaModel.withReplicaApi((context, replicaApi, child) {
      return CImageViewer(
        loadImageFile: replicaApi.getImageBytesFromURL(
          replicaApi.getDownloadAddr(widget.replicaLink),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CText(
              widget.replicaLink.displayName ?? 'untitled'.i18n,
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
            onPressed: () async {
              await replicaApi.download(widget.replicaLink);
              // TODO <08-08-22, kalli> Confirm we can use BotToast
              BotToast.showText(text: 'download_started'.i18n);
            },
            icon: CAssetImage(
              size: 20,
              path: ImagePaths.file_download,
              color: white,
            ),
          ),
        ],
      );
    });
  }
}
