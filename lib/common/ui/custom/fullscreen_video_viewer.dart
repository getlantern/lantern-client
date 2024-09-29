import 'package:lantern/features/messaging/messaging.dart';
import 'package:video_player/video_player.dart';

/// FullScreenVideoViewer extends Viewer and also receives decryption and loading functions from Chat and Replica components. It has no awareness of the video file (Chat or Replica) it displays.
/// It handles tapping/pausing/playing, as well as disabling the screensaver when a video is playing. It also handles video file decryption and loading errors.
class FullScreenVideoViewer extends FullScreenViewer {
  final Function loadVideoFile;
  final Future decryptVideoFile;
  @override
  final Widget? title;
  @override
  final List<Widget>? actions;
  @override
  final Map<String, dynamic>? metadata;
  final Duration? startAtPosition;

  FullScreenVideoViewer({
    required this.loadVideoFile,
    required this.decryptVideoFile,
    this.title,
    this.actions,
    this.metadata,
    this.startAtPosition,
  }) : super();

  @override
  State<StatefulWidget> createState() => FullScreenVideoViewerState();
}

class FullScreenVideoViewerState
    extends FullScreenViewerState<FullScreenVideoViewer> {
  VideoPlayerController? controller;
  var playing = false;
  var _showPlayButton = false;
  var fixRotation = false;

  @override
  void initState() {
    super.initState();
    // first decrypt the video file - only really needed by Chat videos for the moment
    widget.decryptVideoFile.catchError((e, stack) {
      logger.e('Error while decrypting video file: $e, $stack');
    }).then(
      // upon successful decryption, the value (either the String path in case of Chat, or the Replicalink replicaLink in case of Replica) is loaded by the respective loadVideoFile() arguments
      (value) => setState(() {
        controller = widget.loadVideoFile(value)
          ..initialize().then((__) {
            if (widget.startAtPosition != null) {
              controller!.seekTo(widget.startAtPosition!);
            }
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
    super.dispose();
  }

  @override
  bool ready() {
    return controller != null;
  }

  @override
  Widget body(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, controller!.value.position);
        return true;
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // * Display video and play button
          return Stack(
            alignment: Alignment.center,
            children: [
              if (controller == null)
                spinner
              else
              ValueListenableBuilder(
                valueListenable: controller!,
                builder: (
                  BuildContext context,
                  VideoPlayerValue value,
                  Widget? child,
                ) {
                  if (!value.isInitialized) {
                    return spinner;
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
      ),
    );
  }
}
