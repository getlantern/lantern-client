import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/notifications.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

/// ReplicaAudioPlayScreen takes a 'replicaLink' of an audio and attempts to
/// stream it. If it can't stream the link, it'll show an error screen.
///
/// This screen supports landscape and portrait orientations
// TODO <08-08-22, kalli> Will need to move away from audioplayers package
// and use in messaging/conversation/audio
class ReplicaAudioPlayerScreen extends StatefulWidget {
  ReplicaAudioPlayerScreen({
    Key? key,
    required this.replicaApi,
    required this.replicaLink,
    this.mimeType,
  }) : super(key: key);
  final ReplicaApi replicaApi;
  final ReplicaLink replicaLink;
  final String? mimeType;

  @override
  State<StatefulWidget> createState() => _ReplicaAudioPlayerScreenState();
}

class _ReplicaAudioPlayerScreenState extends State<ReplicaAudioPlayerScreen> {
  final mode = PlayerMode.MEDIA_PLAYER;
  final defaultSeekDurationInSeconds = 3;
  late AudioPlayer audioPlayer;
  Duration? totalDuration;
  Duration? position;
  PlayerState playerState = PlayerState.STOPPED;
  StreamSubscription? durationSubscription;
  StreamSubscription? positionSubscription;
  StreamSubscription? playerCompleteSubscription;
  StreamSubscription? playerErrorSubscription;
  StreamSubscription? playerStateSubscription;
  StreamSubscription<PlayerControlCommand>? playerControlCommandSubscription;

  bool get _isPlaying => playerState == PlayerState.PLAYING;

  @override
  void initState() {
    _initAudioPlayer();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    durationSubscription?.cancel();
    positionSubscription?.cancel();
    playerCompleteSubscription?.cancel();
    playerErrorSubscription?.cancel();
    playerStateSubscription?.cancel();
    playerControlCommandSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Audio - TBD');
    // return ReplicaViewerLayout(
    //   context: context,
    //   api: widget.replicaApi,
    //   link: widget.replicaLink,
    //   category: SearchCategory.Audio,
    //   mimeType: widget.mimeType,
    //   backgroundColor: grey2,
    //   body: Center(
    //     child: Padding(
    //       padding: const EdgeInsets.all(30.0),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: <Widget>[
    //           renderPlaybackSliderAndDuration(),
    //           renderPlaybackButtons(),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget renderPlaybackButtons() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fast rewind button
          SizedBox(
            width: 32,
            height: 32,
            child: FloatingActionButton(
              child: const CAssetImage(
                path: ImagePaths.fast_rewind,
                size: 16,
              ),
              onPressed: () async {
                if (position == null) {
                  return;
                }
                position = Duration(
                  seconds: max(
                    0,
                    position!.inSeconds - defaultSeekDurationInSeconds,
                  ).round(),
                );
                await audioPlayer.seek(position!);
              },
            ),
          ),
          const SizedBox(width: 20),

          // Play button
          SizedBox(
            width: 56,
            height: 56,
            child: FloatingActionButton(
              onPressed: () async {
                _isPlaying ? await _pause() : await _play();
              },
              child: CAssetImage(
                path: _isPlaying ? ImagePaths.pause : ImagePaths.play,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Fast forward button
          SizedBox(
            width: 32,
            height: 32,
            child: FloatingActionButton(
              onPressed: () async {
                if (position == null || totalDuration == null) {
                  return;
                }
                position = Duration(
                  seconds: min(
                    totalDuration!.inSeconds,
                    position!.inSeconds + defaultSeekDurationInSeconds,
                  ).round(),
                );
                await audioPlayer.seek(position!);
              },
              child: const CAssetImage(
                path: ImagePaths.fast_forward,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget renderPlaybackSliderAndDuration() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: white,
        ),
        color: white,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      height: 80.0,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Slider(
              onChanged: (v) {
                final duration = totalDuration;
                if (duration == null) {
                  return;
                }
                final Position = v * duration.inMilliseconds;
                audioPlayer.seek(Duration(milliseconds: Position.round()));
              },
              value: (position != null &&
                      totalDuration != null &&
                      position!.inMilliseconds > 0 &&
                      position!.inMilliseconds < totalDuration!.inMilliseconds)
                  ? position!.inMilliseconds / totalDuration!.inMilliseconds
                  : 0.0,
            ),

            // Render the current position duration and total duration at the
            // edges of the container, right below the slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CText(
                    position != null
                        ? position!.toString().split('.').first
                        : '00:00',
                    style: CTextStyle(fontSize: 12.0, lineHeight: 4.0),
                  ),
                  CText(
                    totalDuration != null
                        ? totalDuration!.toString().split('.').first
                        : '00:00',
                    style: CTextStyle(fontSize: 12.0, lineHeight: 4.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initAudioPlayer() {
    audioPlayer = AudioPlayer(mode: mode);
    durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      setState(() => totalDuration = duration);
    });

    positionSubscription = audioPlayer.onAudioPositionChanged.listen(
      (p) => setState(() {
        position = p;
      }),
    );

    playerCompleteSubscription = audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        position = totalDuration;
      });
    });

    playerErrorSubscription = audioPlayer.onPlayerError.listen((msg) {
      logger.w('audioPlayer error : $msg');
      setState(() {
        playerState = PlayerState.STOPPED;
        totalDuration = const Duration();
        position = const Duration();
      });
    });

    playerControlCommandSubscription =
        audioPlayer.notificationService.onPlayerCommand.listen((command) {});

    _play().then((_) {
      setState(() {});
    });
  }

  Future<int> _play() async {
    final playPosition = (position != null &&
            totalDuration != null &&
            position!.inMilliseconds > 0 &&
            position!.inMilliseconds < totalDuration!.inMilliseconds)
        ? position
        : null;
    final result = await audioPlayer.play(
      widget.replicaApi.getDownloadAddr(widget.replicaLink),
      position: playPosition,
    );
    if (result == 1) {
      setState(() => playerState = PlayerState.PLAYING);
    }

    return result;
  }

  Future<int> _pause() async {
    final result = await audioPlayer.pause();
    if (result == 1) {
      setState(() => playerState = PlayerState.PAUSED);
    }
    return result;
  }

  void _onComplete() {
    setState(() => playerState = PlayerState.STOPPED);
  }
}
