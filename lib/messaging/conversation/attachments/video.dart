import 'package:lantern/messaging/conversation/attachments/attachment.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:video_player/video_player.dart';

class VideoAttachment extends VisualAttachment {
  VideoAttachment(Contact contact, StoredMessage message,
      StoredAttachment attachment, bool inbound)
      : super(contact, message, attachment, inbound);

  @override
  Widget buildViewer() => VideoViewer(contact, message, attachment);

  @override
  Widget wrapThumbnail(Widget thumbnail) => Stack(
        alignment: Alignment.center,
        children: [
          thumbnail,
          PlayButton(
            size: 48,
            custom: true,
          )
        ],
      );
}

class VideoViewer extends ViewerWidget {
  final StoredAttachment attachment;

  VideoViewer(Contact contact, StoredMessage message, this.attachment)
      : super(contact, message);

  @override
  State<StatefulWidget> createState() => VideoViewerState();
}

class VideoViewerState extends ViewerState<VideoViewer> {
  VideoPlayerController? controller;
  var playing = false;
  var _showPlayButton = false;

  @override
  void initState() {
    super.initState();
    context.loaderOverlay.show(widget: spinner);
    messagingModel.decryptVideoForPlayback(widget.attachment).catchError((e) {
      context.loaderOverlay.hide();
    }).then((videoFilename) {
      context.loaderOverlay.hide();
      setState(() {
        controller = VideoPlayerController.file(File(videoFilename))
          ..initialize().then((_) {
            setState(() {
              controller?.play();
            });
          });
        controller?.addListener(() {
          if (controller!.value.isPlaying != playing) {
            setState(() {
              playing = !playing;
            });
          }
        });
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    controller = null;
    super.dispose();
  }

  @override
  bool ready() => controller != null;

  @override
  Widget body(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (controller == null) {
        return Container();
      }
      return Stack(
        alignment: Alignment.center,
        children: [
          ValueListenableBuilder(
            valueListenable: controller!,
            builder:
                (BuildContext context, VideoPlayerValue value, Widget? child) {
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
                    },
                    child: AspectRatio(
                      aspectRatio: controller!.value.aspectRatio,
                      child: VideoPlayer(controller!),
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
              onPressed: () {
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
              },
            ),
        ],
      );
    });
  }
}
