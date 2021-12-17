import 'package:lantern/common/common.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/logic/common.dart';
import 'package:lantern/replica/models/replica_link.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:lantern/replica/ui/common.dart';
import 'package:lantern/replica/ui/media_views/playback_button.dart';
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
  bool _playbackControlsVisible = true;
  bool _isPlaying = false;
  Duration _totalDuration = const Duration(seconds: 0);
  Duration _position = const Duration(seconds: 0);
  final ReplicaApi _replicaApi =
      ReplicaApi(ReplicaCommon.getReplicaServerAddr()!);
  final _defaultSeekDurationInSeconds = 3;
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;

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
    _initializeVideoPlayerFuture = _videoController.initialize();

    // Add a listener for video playback changes
    _videoController.addListener(() {
      if (!_videoController.value.isPlaying) {
        return;
      }
      if (mounted) {
        setState(() {
          _position = _videoController.value.position;
          if (_videoController.value.duration != _totalDuration) {
            _totalDuration = _videoController.value.duration;
          }
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
              return Center(
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: Stack(children: [
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            _playbackControlsVisible =
                                !_playbackControlsVisible;
                          });
                        },
                        child: VideoPlayer(_videoController)),
                    // Only render controls if the playback controls are
                    // visible. Just hiding the opacity of the playback
                    // controls is not sufficient since the tap gestures will be
                    // absorbed by the playback controls
                    if (_playbackControlsVisible)
                      Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: white,
                                    ),
                                    color: white.withOpacity(0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20))),
                                height: 120.0,
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    renderPlaybackSlider(),
                                    renderPlaybackButtons()
                                  ],
                                ),
                              )))
                  ]),
                ),
              );
            },
          ),
        ));
  }

  Widget renderPlaybackButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fast-rewind button
        PlaybackButton(
          onTap: () async {
            setState(() {
              _position = Duration(
                  seconds: max(0,
                          _position.inSeconds - _defaultSeekDurationInSeconds)
                      .round());
            });
            await _videoController.seekTo(_position);
          },
          path: ImagePaths.fast_rewind,
          size: 40,
        ),

        const SizedBox(width: 20),

        // Play button
        PlaybackButton(
          onTap: () async {
            setState(() {
              _isPlaying = !_isPlaying;
            });
            _isPlaying
                ? await _videoController.play()
                : await _videoController.pause();
          },
          path: _isPlaying ? ImagePaths.pause : ImagePaths.play,
          size: 60,
        ),

        const SizedBox(width: 20),

        // Fast forward button
        PlaybackButton(
          onTap: () async {
            setState(() {
              _position = Duration(
                  seconds: min(_totalDuration.inSeconds,
                          _position.inSeconds + _defaultSeekDurationInSeconds)
                      .round());
            });
            await _videoController.seekTo(_position);
          },
          path: ImagePaths.fast_forward,
          size: 40,
        ),
      ],
    );
  }

  // XXX <17-12-2021> soltzen: those controls are the same as the audio playback
  // controls.
  Widget renderPlaybackSlider() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Slider(
          onChanged: (v) {
            _position = Duration(
                milliseconds: (v * _totalDuration.inMilliseconds).round());
            _videoController.seekTo(_position);
          },
          value: (_position.inMilliseconds > 0 &&
                  _position.inMilliseconds < _totalDuration.inMilliseconds)
              ? _position.inMilliseconds / _totalDuration.inMilliseconds
              : 0.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CText(
                _position.toString().split('.').first,
                style: CTextStyle(fontSize: 12.0, lineHeight: 4.0),
              ),
              CText(
                _totalDuration.toString().split('.').first,
                style: CTextStyle(fontSize: 12.0, lineHeight: 4.0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
