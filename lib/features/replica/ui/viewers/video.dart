import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/replica/common.dart';
import 'package:lantern/features/replica/ui/viewers/layout.dart';
import 'package:video_player/video_player.dart';

/// Renders an embedded video player with fullscreen option
/// wrapped by our reusable ReplicaViewer layout
@RoutePage(name: 'ReplicaVideoViewer')
class ReplicaVideoViewer extends ReplicaViewerLayout {
  ReplicaVideoViewer({
    required ReplicaApi replicaApi,
    required ReplicaSearchItem item,
    required SearchCategory category,
  }) : super(replicaApi: replicaApi, item: item, category: category);

  @override
  State<StatefulWidget> createState() => _ReplicaVideoViewerState();
}

class _ReplicaVideoViewerState extends ReplicaViewerLayoutState {
  VideoPlayerController? controller;
  var playing = false;
  var _showPlayButton = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      controller = VideoPlayerController.network(
        // 'https://dl8.webmfiles.org/big-buck-bunny_trailer.webm',
        widget.replicaApi.getDownloadAddr(widget.item.replicaLink),
      )..initialize();
      handleListener();
    });
  }

  void handleListener() {
    controller?.addListener(() {
      if (controller!.value.isPlaying != playing) {
        setState(() {
          playing = !playing;
        });
      }
    });
  }

  void handleVideoTap() {
    if (controller!.value.isPlaying) {
      setState(() {
        controller!.pause();
        _showPlayButton = true;
      });
    } else {
      setState(() {
        controller!.play();
        _showPlayButton = false;
      });
    }
  }

  @override
  bool ready() => controller != null;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget body(BuildContext context) {
    return Flexible(
      flex: 1,
      child: ClipRRect(
        borderRadius: defaultBorderRadius,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            ValueListenableBuilder(
              valueListenable: controller!,
              builder: (
                BuildContext context,
                VideoPlayerValue videoResult,
                Widget? child,
              ) {
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    // * Video
                    // https://github.com/flutter/plugins/blob/master/packages/video_player/video_player/example/lib/main.dart
                    GestureDetector(
                      onTap: () {
                        setState(() => _showPlayButton = !_showPlayButton);
                        Future.delayed(
                          defaultTransitionDuration,
                          () => handleVideoTap(),
                        );
                      },
                      child: videoResult.isInitialized
                          ? VideoPlayer(controller!)
                          : const Center(child: CircularProgressIndicator()),
                    ),
                    // * Scrubber
                    if (videoResult.isInitialized)
                      VideoProgressIndicator(
                        controller!,
                        allowScrubbing: true,
                        padding: const EdgeInsets.only(bottom: 32.0),
                      ),
                    // * Play and full screen buttons
                    if (videoResult.isInitialized)
                      Container(
                        color: videoControlsGrey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Play
                            Container(
                              margin: const EdgeInsetsDirectional.only(
                                start: 8.0,
                                bottom: 2.0,
                              ),
                              child: RoundButton(
                                diameter: 24,
                                padding: 0,
                                backgroundColor: transparent,
                                icon: CAssetImage(
                                  size: 24,
                                  color: white,
                                  path: playing
                                      ? ImagePaths.pause
                                      : ImagePaths.play,
                                ),
                                onPressed: () => handleVideoTap(),
                              ),
                            ),
                            // Maximize
                            Container(
                              margin: const EdgeInsetsDirectional.only(
                                end: 8.0,
                                bottom: 2.0,
                              ),
                              child: RoundButton(
                                diameter: 30,
                                padding: 0,
                                backgroundColor: transparent,
                                icon: CAssetImage(
                                  size: 30,
                                  color: white,
                                  path: ImagePaths.fullscreen_icon,
                                ),
                                onPressed: () {
                                  handleVideoTap();
                                  launchFullScreen(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future launchFullScreen(BuildContext context) async => await context.router
          .push(
        FullScreenDialogPage(
          widget: FullScreenVideoViewer(
            startAtPosition: controller!.value.position,
            // feels hacky...explanation: we don't need to decrypt videos for Replica,so we create a "fake" future that returns replicaLink when resolved (replicaLink is needed by loadVideoFile below)
            decryptVideoFile: Future.value(widget.item.replicaLink),
            loadVideoFile: (ReplicaLink replicaLink) =>
                VideoPlayerController.network(
              widget.replicaApi.getViewAddr(replicaLink),
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
                  SearchCategory.Video.toShortString(),
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
      )
          // When we exit full screen, we need to update this controller to the video position we were just at
          .then((value) {
        final seekToPosition = value as Duration;
        controller!.seekTo(seekToPosition);
      });
}
