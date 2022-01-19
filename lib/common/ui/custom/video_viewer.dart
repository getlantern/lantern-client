import 'package:lantern/messaging/messaging.dart';
import 'package:video_player/video_player.dart';

class CVideoViewer extends ViewerWidget {
  final Function loadVideoFile;
  final Future decryptVideoFile;
  @override
  final Widget? title;
  @override
  final List<Widget>? actions;
  @override
  final Map<String, dynamic>? metadata;

  CVideoViewer({
    required this.loadVideoFile,
    required this.decryptVideoFile,
    this.title,
    this.actions,
    this.metadata,
  }) : super();

  @override
  State<StatefulWidget> createState() => CVideoViewerState();
}

class CVideoViewerState extends ViewerState<CVideoViewer> {
  VideoPlayerController? controller;
  var playing = false;
  var _showPlayButton = false;
  var fixRotation = false;

  @override
  void initState() {
    super.initState();
    context.loaderOverlay.show(widget: spinner);
    widget.decryptVideoFile.catchError((e, stack) {
      logger.e('Error while decrypting video file: $e, $stack');
    }).then(
      (value) => setState(() {
        context.loaderOverlay.hide();
        controller = widget.loadVideoFile(value)
          ..initialize().then((__) {
            updateController(widget.metadata?['rotation']);
          });
        handleListener();
      }),
    );
  }

  void updateController(String? rotation) {
    setState(() {
      fixRotation = rotation == '180';
      controller?.play().then((_) async {
        // update UI after playing stops
        setState(() {});
      });
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

  void handleButtonTap() {
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
  void dispose() {
    controller?.dispose();
    controller = null;
    Wakelock.disable();
    super.dispose();
  }

  @override
  bool ready() => controller != null;

  @override
  Widget body(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (controller == null) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Flexible(
                  child: CText(
                    'video_stream_error'.i18n,
                    style: CTextStyle(
                      fontSize: 16,
                      color: white,
                      lineHeight: 19,
                    ),
                  ),
                )
              ],
            ),
          );
        }

        Wakelock.toggle(
          enable: controller!.value.isPlaying,
        );

        return Stack(
          alignment: Alignment.center,
          children: [
            ValueListenableBuilder(
              valueListenable: controller!,
              builder: (
                BuildContext context,
                VideoPlayerValue value,
                Widget? child,
              ) {
                if (!value.isInitialized) {
                  return const SizedBox();
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
                          () => handleButtonTap(),
                        );
                      },
                      child: AspectRatio(
                        aspectRatio: controller!.value.aspectRatio,
                        child: fixRotation
                            ? Transform.rotate(
                                angle: pi,
                                child: VideoPlayer(controller!),
                              )
                            : VideoPlayer(controller!),
                      ),
                    ),
                    mirrorLTR(
                      context: context,
                      child: VideoProgressIndicator(
                        controller!,
                        allowScrubbing: true,
                      ),
                    ),
                  ],
                );
              },
            ),
            // button goes in main stack
            if (_showPlayButton)
              PlayButton(
                size: 48,
                custom: true,
                playing: controller!.value.isPlaying,
                onPressed: () => handleButtonTap(),
              ),
          ],
        );
      },
    );
  }
}
