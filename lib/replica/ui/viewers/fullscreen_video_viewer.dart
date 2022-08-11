import 'package:video_player/video_player.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

/// FullscreenReplicaVideoViewer takes a 'replicaLink' of a video and attempts to stream it. CVideoViewer handles orientation and errors.
// TODO <08-08-22, kalli> Update to reflect Figma
class FullscreenReplicaVideoViewer extends StatelessWidget {
  FullscreenReplicaVideoViewer({
    Key? key,
    required this.replicaApi,
    required this.replicaLink,
    this.mimeType,
  }) : super(key: key);
  final ReplicaApi replicaApi;
  final ReplicaLink replicaLink;
  final String? mimeType;

  @override
  Widget build(BuildContext context) {
    return FullScreenDialog(
      widget: CVideoViewer(
        decryptVideoFile: Future.value(
          replicaLink,
        ), // feels hacky...explanation: we don't need to decrypt videos for Replica,so we create a "fake" future that returns replicaLink when resolved (replicaLink is needed by loadVideoFile below)
        loadVideoFile: (ReplicaLink replicaLink) =>
            VideoPlayerController.network(
          replicaApi.getViewAddr(replicaLink),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CText(
              replicaLink.displayName ?? 'untitled'.i18n,
              style: tsHeading3.copiedWith(color: white),
            ),
            if (mimeType != null)
              CText(
                mimeType!,
                style: tsOverline.copiedWith(color: white),
              )
            else
              CText(
                SearchCategory.Video.toShortString(),
                style: tsOverline.copiedWith(color: white),
              )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await replicaApi.download(replicaLink);
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
      ),
    );
  }
}
