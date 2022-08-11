import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

/// ReplicaImageFullScreenViewer renders a full screen Replica image. It uses CImageViewer() to handle tapping and support landscape and portrait orientations.
class ReplicaImageFullScreenViewer extends StatefulWidget {
  ReplicaImageFullScreenViewer({Key? key, required this.replicaLink});

  final ReplicaLink replicaLink;

  @override
  State<ReplicaImageFullScreenViewer> createState() =>
      _ReplicaImageFullScreenViewerState();
}

class _ReplicaImageFullScreenViewerState
    extends State<ReplicaImageFullScreenViewer> {
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
