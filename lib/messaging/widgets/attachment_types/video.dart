import 'dart:io';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:video_player/video_player.dart';

class VideoAttachment extends StatefulWidget {
  final StoredAttachment attachment;

  VideoAttachment(this.attachment);

  @override
  VideoAttachmentState createState() => VideoAttachmentState();
}

class VideoAttachmentState extends State<VideoAttachment> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    // we are first downloading attachments and then decrypting them by calling _getDecryptedAttachment() in the FutureBuilder
    switch (widget.attachment.status) {
      case StoredAttachment_Status.PENDING_UPLOAD:
        // pending download
        return Transform.scale(
            scale: 0.5, child: const CircularProgressIndicator());
      case StoredAttachment_Status.FAILED:
        // error with download
        return const Icon(Icons.error_outlined);
      default:
        // successful download, onto decrypting
        return Container(
          child: FutureBuilder(
              future: model.thumbnail(widget.attachment),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Transform.scale(
                        scale: 0.5, child: const CircularProgressIndicator());
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return const Icon(Icons.error_outlined);
                    }
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        _controller?.value.isPlaying ?? false
                            ? AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              )
                            : Image.memory(snapshot.data,
                                filterQuality: FilterQuality.high, scale: 3),
                        IconButton(
                            iconSize: 96,
                            icon: Icon(_controller?.value.isPlaying ?? false
                                ? Icons.stop_circle_outlined
                                : Icons.play_circle_outline),
                            onPressed: () {
                              if (_controller?.value.isPlaying ?? false) {
                                setState(() {
                                  _controller?.pause();
                                });
                                return;
                              }

                              // TODO: properly handle resumption of paused video
                              // dispose existing video controller if necessary
                              _controller?.dispose();
                              model
                                  .decryptVideoForPlayback(widget.attachment)
                                  .then((videoFilename) {
                                setState(() {
                                  _controller = VideoPlayerController.file(
                                      File(videoFilename))
                                    ..initialize().then((_) {
                                      setState(() {
                                        _controller?.play().then((_) {
                                          // update UI after playing stops
                                          setState(() {});
                                        });
                                      });
                                    });
                                });
                              });
                            }),
                      ],
                    );
                  default:
                    return const Icon(Icons.image);
                }
              }),
        );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }
}
