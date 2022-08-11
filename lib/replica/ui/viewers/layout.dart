import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';
import 'package:video_player/video_player.dart';

class ReplicaViewerLayout extends StatefulWidget {
  ReplicaViewerLayout({
    Key? key,
    required this.replicaApi,
    required this.item,
    required this.category,
  }) : super(key: key);

  final ReplicaApi replicaApi;
  final ReplicaSearchItem item;
  final SearchCategory category;

  @override
  State<ReplicaViewerLayout> createState() => _ReplicaViewerLayoutState();
}

class _ReplicaViewerLayoutState extends State<ReplicaViewerLayout> {
  VideoPlayerController? controller;
  var playing = false;
  var _showPlayButton = false;
  late final Future decryptVideoFile = Future.value(widget.item.replicaLink);

  @override
  void initState() {
    super.initState();
    // first decrypt the video file - only really needed by Chat videos for the moment
    decryptVideoFile.catchError((e, stack) {
      logger.e('Error while decrypting video file: $e, $stack');
    }).then(
      // upon successful decryption, the value (either the String path in case of Chat, or the Replicalink replicaLink in case of Replica) is loaded by the respective loadVideoFile() arguments
      (value) => setState(() {
        controller = VideoPlayerController.network(
          widget.replicaApi.getViewAddr(widget.item.replicaLink),
        );
        handleListener();
      }),
    );
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
  Widget build(BuildContext context) {
    return BaseScreen(
      showAppBar: true,
      padHorizontal: true,
      title: Container(
        padding: const EdgeInsetsDirectional.only(
          bottom: 6.0,
        ),
        alignment: Alignment.centerLeft,
        child: (widget.item.primaryMimeType != null)
            ? CText(
                'replica_layout_filetype'
                    .i18n
                    .fill([widget.item.primaryMimeType!]),
                style: tsSubtitle1,
              )
            : CText(
                widget.category.toShortString(),
                style: tsSubtitle1,
              ),
      ),
      actions: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsetsDirectional.only(
            end: 12.0,
          ),
          child: CText(
            widget.item.humanizedFileSize,
            style: tsButton,
          ),
        ),
      ],
      body: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 12.0,
          end: 12.0,
          top: 24.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            renderPreview(widget.category),
            renderText(),
          ],
        ),
      ),
    );
  }

  Widget renderPreview(SearchCategory category) {
    switch (category) {
      case SearchCategory.Image:
        return renderImageThumbnail(
          replicaApi: widget.replicaApi,
          item: widget.item,
        );
      case SearchCategory.Video:
        // * Error handling
        if (controller == null) {
          return Text('video_stream_error'.i18n);
        }

        // * Display video and play button
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
                  return Text('not initialized');
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
                        child: VideoPlayer(controller!),
                      ),
                    ),
                    VideoProgressIndicator(
                      controller!,
                      allowScrubbing: true,
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
      case SearchCategory.Audio:
        return Text('Audio preview');
      case SearchCategory.Document:
        return Text('Document preview');
      case SearchCategory.Unknown:
        return Text('Unknown icon');
      case SearchCategory.App:
        return Text('App icon');
      default:
        return Text('oops I do not know how to render this!');
    }
  }

  Widget renderText() {
    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // * Title
            Container(
              padding: const EdgeInsetsDirectional.only(
                top: 24.0,
                bottom: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CText(
                      widget.item.displayName,
                      style: tsHeading3,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await widget.replicaApi.download(widget.item.replicaLink);
                      // TODO <08-08-22, kalli> Confirm we can use BotToast
                      BotToast.showText(text: 'download_started'.i18n);
                    },
                    icon: const CAssetImage(
                      size: 20,
                      path: ImagePaths.file_download,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: black,
            ),
            // * Description
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsetsDirectional.only(
                top: 24.0,
                bottom: 64.0,
              ),
              child: CText(
                widget.item.description.isEmpty
                    ? 'empty_description'.i18n
                    : widget.item.description,
                style: widget.item.description.isEmpty
                    ? tsSubtitle1.copiedWith(
                        fontStyle: FontStyle.italic,
                      )
                    : tsSubtitle1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
