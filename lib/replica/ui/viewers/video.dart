import 'package:video_player/video_player.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';
import 'package:lantern/replica/ui/viewers/layout.dart';

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
        widget.replicaApi.getViewAddr(widget.item.replicaLink),
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
    Wakelock.toggle(enable: controller!.value.isPlaying);
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
  Widget body(BuildContext context) {
    return Flexible(
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
                if (!videoResult.isInitialized) {
                  return Container(
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                }
                return Stack(
                  fit: StackFit.passthrough,
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    // https://github.com/flutter/plugins/blob/master/packages/video_player/video_player/example/lib/main.dart
                    GestureDetector(
                      onTap: () {
                        setState(() => _showPlayButton = !_showPlayButton);
                        Future.delayed(
                          defaultTransitionDuration,
                          () => handleVideoTap(),
                        );
                      },
                      child: AspectRatio(
                        aspectRatio: controller!.value.aspectRatio,
                        child: VideoPlayer(controller!),
                      ),
                    ),
                    VideoProgressIndicator(
                      controller!,
                      allowScrubbing: true,
                      padding: const EdgeInsets.only(bottom: 36.0),
                    ),
                  ],
                );
              },
            ),
            // * Play and full screen butons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
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
                      path: playing ? ImagePaths.pause : ImagePaths.play,
                    ),
                    onPressed: () => handleVideoTap(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
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
                    // TODO <08-11-22, kalli> This should take into account where we are in the video duration
                    onPressed: () => launchFullScreen(
                      context,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future launchFullScreen(BuildContext context) async {
    return await context.router.push(
      FullScreenDialogPage(
        widget: FullScreenVideoViewer(
          decryptVideoFile: Future.value(
            widget.item.replicaLink,
          ), // feels hacky...explanation: we don't need to decrypt videos for Replica,so we create a "fake" future that returns replicaLink when resolved (replicaLink is needed by loadVideoFile below)
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
              onPressed: () async {
                await widget.replicaApi.download(widget.item.replicaLink);
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
      ),
    );
  }
}
