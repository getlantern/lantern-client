import 'package:lantern/messaging/conversation/attachments/attachment.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:video_player/video_player.dart';

class VideoAttachment extends VisualAttachment {
  VideoAttachment(Contact contact, StoredMessage message,
      StoredAttachment attachment, bool inbound)
      : super(contact, message, attachment, inbound);

  @override
  Widget buildViewer(MessagingModel model) =>
      VideoViewer(model, contact, message, attachment);

  @override
  Widget wrapThumbnail(Widget thumbnail) => Stack(
        alignment: Alignment.center,
        children: [
          thumbnail,
          PlayButton(
            size: 48,
            backgroundColor: black,
            color: white,
          )
        ],
      );
}

class VideoViewer extends ViewerWidget {
  final MessagingModel model;
  final StoredAttachment attachment;

  VideoViewer(
      this.model, Contact contact, StoredMessage message, this.attachment)
      : super(contact, message);

  @override
  State<StatefulWidget> createState() => VideoViewerState();
}

class VideoViewerState extends ViewerState<VideoViewer> {
  VideoPlayerController? controller;
  var playing = false;

  @override
  void initState() {
    super.initState();
    context.loaderOverlay.show();
    widget.model.decryptVideoForPlayback(widget.attachment).catchError((e) {
      context.loaderOverlay.hide();
    }).then((videoFilename) {
      context.loaderOverlay.hide();
      setState(() {
        controller = VideoPlayerController.file(File(videoFilename))
          ..initialize().then((_) {
            if (controller!.value.aspectRatio > 1) {
              // force landscape
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeRight,
                DeviceOrientation.landscapeLeft,
              ]);
            }
            setState(() {
              controller?.play().then((_) {
                // update UI after playing stops
                setState(() {});
              });
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
                  AspectRatio(
                    aspectRatio: controller!.value.aspectRatio,
                    // we rotate landscape videos as a workaround for
                    // https://github.com/flutter/flutter/issues/62400
                    child: Transform.rotate(
                      angle: controller!.value.aspectRatio > 1 ? pi : 0,
                      child: VideoPlayer(controller!),
                    ),
                  ),
                  VideoProgressIndicator(controller!, allowScrubbing: true),
                ],
              );
            },
          ),
          // button goes in main stack
          PlayButton(
            size: 48,
            playing: playing,
            backgroundColor: black,
            onPressed: () {
              if (controller!.value.isPlaying) {
                controller!.pause();
              } else {
                controller!.play();
              }
            },
          ),
        ],
      );
    });
  }
}
