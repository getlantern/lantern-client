import 'package:lantern/common/common.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/logic/common.dart';
import 'package:lantern/replica/models/replica_link.dart';
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
  ReplicaVideoPlayerScreen({Key? key, required this.replicaLink, this.mimeType})
      : super(key: key);
  final ReplicaLink replicaLink;
  final String? mimeType;

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<ReplicaVideoPlayerScreen> {
  final ReplicaApi _replicaApi =
      ReplicaApi(ReplicaCommon.getReplicaServerAddr()!);
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;

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
        _replicaApi.getViewAddr(widget.replicaLink));
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return renderReplicaMediaViewScreen(
        context: context,
        api: _replicaApi,
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
                    'Received a playback error: ${_videoController.value.errorDescription ?? snapshot.error}');
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
                            fontSize: 16, color: white, lineHeight: 19),
                      ))
                    ]));
              }

              // Else, render video
              return Stack(
                alignment: Alignment.center,
                children: [
                  Stack(
                    fit: StackFit.passthrough,
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      ),
                      mirrorLTR(
                          context: context,
                          child: VideoProgressIndicator(_videoController,
                              allowScrubbing: true)),
                    ],
                  ),
                  // button goes in main stack
                  PlayButton(
                    size: 48,
                    custom: true,
                    playing: _isPlaying,
                    onPressed: () {
                      if (_isPlaying) {
                        _videoController.pause();
                      } else {
                        _videoController.play();
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ));
  }
}
