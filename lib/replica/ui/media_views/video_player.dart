import 'package:lantern/common/common.dart';
import 'package:lantern/common/ui/custom/video_viewer.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/models/replica_link.dart';

/// ReplicaVideoPlayerScreen takes a 'replicaLink' of a video and attempts to
/// stream it. If it can't stream the link, it'll show an error screen.
///
/// This screen supports landscape and portrait orientations
///
/// The playback controls container are shown/hidden by tapping away from the
/// playback controls
class ReplicaVideoPlayerScreen extends StatelessWidget {
  ReplicaVideoPlayerScreen({
    Key? key,
    required this.replicaApi,
    required this.replicaLink,
    this.mimeType,
    this.foregroundColor,
  }) : super(key: key);
  final ReplicaApi replicaApi;
  final ReplicaLink replicaLink;
  final String? mimeType;
  final Color? foregroundColor;

  Widget buildViewer() => CVideoViewer(
          ReplicaViewerProps(
            replicaApi,
            replicaLink,
            mimeType,
          ),
          null,
          // * title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CText(
                replicaLink.displayName ?? 'untitled'.i18n,
                style: tsHeading3.copiedWith(color: foregroundColor ?? white),
              ),
              if (mimeType != null)
                CText(
                  mimeType!,
                  style: tsOverline.copiedWith(color: foregroundColor ?? white),
                )
            ],
          ),
          // * actions
          [
            IconButton(
              onPressed: () async {
                await replicaApi.download(replicaLink);
                BotToast.showText(text: 'download_started'.i18n);
              },
              icon: CAssetImage(
                size: 20,
                path: ImagePaths.file_download,
                color: foregroundColor ?? white,
              ),
            ),
          ]);

  @override
  Widget build(BuildContext context) {
    return FullScreenDialog(
      widget: buildViewer(),
    );
  }
}
