import 'dart:io';
import 'dart:typed_data';

import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/attachment_builder.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

class VideoAttachment extends StatelessWidget {
  final StoredAttachment attachment;
  final bool inbound;

  VideoAttachment(this.attachment, this.inbound);

  @override
  Widget build(BuildContext context) {
    return AttachmentBuilder(
        attachment: attachment,
        inbound: inbound,
        defaultIcon: Icons.image,
        builder: (BuildContext context, Uint8List thumbnail) {
          var image = Image.memory(thumbnail,
              errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) =>
                  Icon(Icons.error_outlined,
                      color: inbound ? inboundMsgColor : outboundMsgColor),
              filterQuality: FilterQuality.high);
          return _VideoAttachment(attachment, inbound, image);
        });
  }
}

class _VideoAttachment extends StatefulWidget {
  final StoredAttachment attachment;
  final bool inbound;
  final Image image;

  _VideoAttachment(this.attachment, this.inbound, this.image);

  @override
  _VideoAttachmentState createState() => _VideoAttachmentState();
}

class _VideoAttachmentState extends State<_VideoAttachment> {
  VideoPlayerController? _controller;
  var _playing = false;
  var _reachedEnd = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _disposeControllerIfReachedEnd();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _controller = null;
  }

  void _disposeControllerIfReachedEnd() {
    if (_reachedEnd) {
      // video already reached end, start from beginning
      _controller!.dispose();
      setState(() {
        _controller = null;
        _reachedEnd = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return Stack(
      alignment: Alignment.center,
      children: [
        // Always render the thumbnail in order to preserve the size of the stack
        // while the video starts playing
        SizedBox(
          // this box keeps the video from being too tall
          height: 80.w,
          child: FittedBox(
            child: widget.image,
          ),
        ),
        if (_controller != null)
          ValueListenableBuilder(
              valueListenable: _controller!,
              builder: (BuildContext context, VideoPlayerValue value,
                  Widget? child) {
                if (!value.isInitialized) {
                  return Container();
                }
                return SizedBox(
                  // Size video to the same absolute size as the thumbnail
                  // This will get scaled to fit into the message bubble by the
                  // containing AttachmentBuilder.
                  width: 80.w * value.aspectRatio,
                  height: 80.w,
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        // https://github.com/flutter/plugins/blob/master/packages/video_player/video_player/example/lib/main.dart
                        VideoPlayer(_controller!),
                        VideoProgressIndicator(_controller!,
                            allowScrubbing: true),
                      ],
                    ),
                  ),
                );
              }),
        // button goes in main stack
        SizedBox(
          width: 96,
          height: 96,
          child: FittedBox(
            child: IconButton(
                icon: Icon(
                    _playing
                        ? Icons.stop_circle_outlined
                        : Icons.play_circle_outline,
                    color: widget.inbound ? inboundMsgColor : outboundMsgColor),
                onPressed: () {
                  _disposeControllerIfReachedEnd();

                  if (_controller != null) {
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();
                    } else {
                      _controller!.play();
                    }
                    return;
                  }

                  context.loaderOverlay.show();
                  model
                      .decryptVideoForPlayback(widget.attachment)
                      .catchError((e) {
                    context.loaderOverlay.hide();
                  }).then((videoFilename) {
                    context.loaderOverlay.hide();
                    setState(() {
                      _controller =
                          VideoPlayerController.file(File(videoFilename))
                            ..initialize().then((_) {
                              setState(() {
                                _controller?.play().then((_) {
                                  // update UI after playing stops
                                  setState(() {});
                                });
                              });
                            });
                      _controller?.addListener(() {
                        if (_controller!.value.isPlaying != _playing) {
                          setState(() {
                            _playing = !_playing;
                            if (!_playing &&
                                _controller!.value.position ==
                                    _controller!.value.duration) {
                              // reached end of video, mark for reset
                              _reachedEnd = true;
                            }
                          });
                        }
                      });
                    });
                  });
                }),
          ),
        ),
      ],
    );
  }
}
