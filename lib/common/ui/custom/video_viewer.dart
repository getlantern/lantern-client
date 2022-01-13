import 'package:lantern/messaging/messaging.dart';
import 'package:video_player/video_player.dart';
import 'viewer.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class CVideoViewer extends ViewerWidget {
  @override
  final ReplicaViewerProps? replicaProps;
  @override
  final MessagingViewerProps? messagingProps;
  @override
  final Widget? title;
  @override
  final List<Widget>? actions;

  CVideoViewer(this.replicaProps, this.messagingProps, this.title, this.actions)
      : super(replicaProps, messagingProps, title, actions);

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

    // * Playing video in Chat
    if (widget.messagingProps != null) initMessagingVideoPlayer();

    // * Playing video in Replica
    if (widget.replicaProps != null) initReplicaVideoPlayer();
  }

  void initMessagingVideoPlayer() {
    messagingModel
        .decryptVideoForPlayback(widget.messagingProps!.attachment)
        .catchError((e) {
      context.loaderOverlay.hide();
    }).then((videoFilename) {
      context.loaderOverlay.hide();
      final rotation =
          widget.messagingProps!.attachment.attachment.metadata['rotation'];
      setState(() {
        controller = VideoPlayerController.file(File(videoFilename))
          ..initialize().then((_) {
            updateController(rotation);
          });
        handleListener();
      });
    });
  }

  void initReplicaVideoPlayer() {
    logger.v('replicaProps ${widget.replicaProps}');
    context.loaderOverlay.hide();
    setState(() {
      controller = VideoPlayerController.network(
        widget.replicaProps!.replicaApi
            .getViewAddr(widget.replicaProps!.replicaLink),
      )..initialize().then((_) {
          updateController(null);
        });
    });
    handleListener();
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
