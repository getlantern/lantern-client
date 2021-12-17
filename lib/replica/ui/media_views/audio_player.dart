import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/notifications.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/logic/common.dart';
import 'package:lantern/replica/models/replica_link.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:lantern/replica/ui/common.dart';
import 'package:lantern/replica/ui/media_views/playback_button.dart';
import 'package:logger/logger.dart' as log;

var logger = log.Logger(
  printer: log.PrettyPrinter(),
);

/// ReplicaAudioPlayScreen takes a 'replicaLink' of an audio and attempts to
/// stream it. If it can't stream the link, it'll show an error screen.
///
/// This screen supports landscape and portrait orientations
class ReplicaAudioPlayerScreen extends StatefulWidget {
  ReplicaAudioPlayerScreen({Key? key, required this.replicaLink, this.mimeType})
      : super(key: key);
  final ReplicaLink replicaLink;
  final String? mimeType;

  @override
  State<StatefulWidget> createState() => _ReplicaAudioPlayerScreenState();
}

class _ReplicaAudioPlayerScreenState extends State<ReplicaAudioPlayerScreen> {
  final ReplicaApi _replicaApi =
      ReplicaApi(ReplicaCommon.getReplicaServerAddr()!);
  final mode = PlayerMode.MEDIA_PLAYER;
  final _defaultSeekDurationInSeconds = 3;
  late AudioPlayer _audioPlayer;
  Duration? _totalDuration;
  Duration? _position;
  PlayerState _playerState = PlayerState.STOPPED;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerErrorSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription<PlayerControlCommand>? _playerControlCommandSubscription;
  bool get _isPlaying => _playerState == PlayerState.PLAYING;

  @override
  void initState() {
    _initAudioPlayer();
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _playerControlCommandSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return renderReplicaMediaViewScreen(
        context: context,
        api: _replicaApi,
        link: widget.replicaLink,
        category: SearchCategory.Audio,
        mimeType: widget.mimeType,
        backgroundColor: grey2,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                renderPlaybackSliderAndDuration(),
                renderPlaybackButtons(),
              ],
            ),
          ),
        ));
  }

  Widget renderPlaybackButtons() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fast rewind button
          PlaybackButton(
            onTap: () async {
              if (_position == null) {
                return;
              }
              _position = Duration(
                  seconds: max(0,
                          _position!.inSeconds - _defaultSeekDurationInSeconds)
                      .round());
              await _audioPlayer.seek(_position!);
            },
            path: ImagePaths.fast_rewind,
            size: 40,
          ),
          const SizedBox(width: 20),

          // Play button
          PlaybackButton(
            onTap: () async {
              _isPlaying ? await _pause() : await _play();
            },
            path: _isPlaying ? ImagePaths.pause : ImagePaths.play,
            size: 60,
          ),
          const SizedBox(width: 20),

          // Fast forward button
          PlaybackButton(
            onTap: () async {
              if (_position == null || _totalDuration == null) {
                return;
              }
              _position = Duration(
                  seconds: min(_totalDuration!.inSeconds,
                          _position!.inSeconds + _defaultSeekDurationInSeconds)
                      .round());
              await _audioPlayer.seek(_position!);
            },
            path: ImagePaths.fast_forward,
            size: 40,
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
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      height: 80.0,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Slider(
              onChanged: (v) {
                final duration = _totalDuration;
                if (duration == null) {
                  return;
                }
                final Position = v * duration.inMilliseconds;
                _audioPlayer.seek(Duration(milliseconds: Position.round()));
              },
              value: (_position != null &&
                      _totalDuration != null &&
                      _position!.inMilliseconds > 0 &&
                      _position!.inMilliseconds <
                          _totalDuration!.inMilliseconds)
                  ? _position!.inMilliseconds / _totalDuration!.inMilliseconds
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
                    _position != null
                        ? _position!.toString().split('.').first
                        : '00:00',
                    style: CTextStyle(fontSize: 12.0, lineHeight: 4.0),
                  ),
                  CText(
                    _totalDuration != null
                        ? _totalDuration!.toString().split('.').first
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
    _audioPlayer = AudioPlayer(mode: mode);
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _totalDuration = duration);
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _totalDuration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      logger.w('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.STOPPED;
        _totalDuration = const Duration();
        _position = const Duration();
      });
    });

    _playerControlCommandSubscription =
        _audioPlayer.notificationService.onPlayerCommand.listen((command) {});
  }

  Future<int> _play() async {
    final playPosition = (_position != null &&
            _totalDuration != null &&
            _position!.inMilliseconds > 0 &&
            _position!.inMilliseconds < _totalDuration!.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(
        _replicaApi.getDownloadAddr(widget.replicaLink),
        position: playPosition);
    if (result == 1) {
      setState(() => _playerState = PlayerState.PLAYING);
    }

    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) {
      setState(() => _playerState = PlayerState.PAUSED);
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.STOPPED);
  }
}
