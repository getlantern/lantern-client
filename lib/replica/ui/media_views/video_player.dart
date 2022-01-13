import 'package:lantern/common/common.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/models/replica_link.dart';
import 'package:lantern/replica/models/replica_model.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:lantern/replica/ui/common.dart';
import 'package:logger/logger.dart';
import 'package:video_player/video_player.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

/// ReplicaVideoPlayerScreen takes a 'replicaLink' of a video and attempts to
/// stream it. If it can't stream the link, it'll show an error screen.
///
/// This screen supports landscape and portrait orientations
///
/// The playback controls container are shown/hidden by tapping away from the
/// playback controls
class ReplicaVideoPlayerScreen extends StatefulWidget {
  ReplicaVideoPlayerScreen({
    Key? key,
    required this.replicaApi,
    required this.replicaLink,
    this.mimeType,
  }) : super(key: key);
  final ReplicaApi replicaApi;
  final ReplicaLink replicaLink;
  final String? mimeType;

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

// TODO: a lot of this code is duplicated with video.dart, should consolidate
class _VideoPlayerScreenState extends State<ReplicaVideoPlayerScreen> {
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  var _isPlaying = false;
  var _showPlayButton = false;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);

    // XXX <10-11-21, soltzen> Failures for this call are handled after the
    // future returned in the 'build()' function (see
    // _videoController.value.hasError usage in FutureBuilder)
    _videoController = VideoPlayerController.network(
      widget.replicaApi.getViewAddr(widget.replicaLink),
    );
    _initializeVideoPlayerFuture =
        _videoController.initialize().then((_) => _videoController.play());

    // Add a listener for video playback changes
    _videoController.addListener(() {
      if (_videoController.value.isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = !_isPlaying;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _videoController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return replicaModel.withReplicaApi((context, replicaApi, child) {
      return renderReplicaMediaViewScreen(
        context: context,
        api: replicaApi,
        link: widget.replicaLink,
        category: SearchCategory.Video,
        backgroundColor: black,
        foregroundColor: white,
        mimeType: widget.mimeType,
        body: Padding(
          padding: const EdgeInsetsDirectional.only(top: 8.0),
          child: FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              // If not done, show progress indicator
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // If error, show error with text
              if (_videoController.value.hasError || snapshot.hasError) {
                logger.e(
                  'Received a playback error: ${_videoController.value.errorDescription ?? snapshot.error}',
                );
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

              // Else, render video
              Wakelock.toggle(enable: _videoController.value.isPlaying);
              return Stack(
                alignment: Alignment.center,
                children: [
                  Stack(
                    fit: StackFit.passthrough,
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          setState(() => _showPlayButton = !_showPlayButton);
                          Future.delayed(
                            defaultTransitionDuration,
                            () => handleButtonTap(),
                          );
                        },
                        child: AspectRatio(
                          aspectRatio: _videoController.value.aspectRatio,
                          child: VideoPlayer(_videoController),
                        ),
                      ),
                      mirrorLTR(
                        context: context,
                        child: VideoProgressIndicator(
                          _videoController,
                          allowScrubbing: true,
                        ),
                      ),
                    ],
                  ),
                  // button goes in main stack
                  if (_showPlayButton)
                    PlayButton(
                      size: 48,
                      custom: true,
                      playing: _isPlaying,
                      onPressed: () => handleButtonTap(),
                    ),
                ],
              );
            },
          ),
        ),
      );
    });
  }

  void handleButtonTap() {
    if (_isPlaying) {
      setState(() {
        _videoController.pause();
        _showPlayButton = true;
      });
    } else {
      setState(() {
        _videoController.play();
        _showPlayButton = false;
      });
    }
  }
}
