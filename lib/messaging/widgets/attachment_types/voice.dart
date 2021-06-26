import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/audio_store.dart';

/// An attachment that shows an audio player.
enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class VoiceMemo extends StatefulWidget {
  final StoredAttachment attachment;

  VoiceMemo(this.attachment);

  @override
  State<StatefulWidget> createState() {
    return VoiceMemoState();
  }
}

class VoiceMemoState extends State<VoiceMemo> {
  AudioStore audioStore = AudioStore();
  MessagingModel? model;
  AudioPlayerState? _audioPlayerState;
  Duration? _duration;
  Duration? _position;
  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerErrorSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription<PlayerControlCommand>? _playerControlCommandSubscription;
  bool get _isPlaying => _playerState == PlayerState.playing;
  bool get _isPaused => _playerState == PlayerState.paused;
  String get _positionText => _position?.toString().split('.').first ?? '';

  Future<int> _pause() async {
    final result = await audioStore.pause();
    if (result == 1 && mounted) {
      setState(() => _playerState = PlayerState.paused);
    }
    return result;
  }

  Future<int> _stop() async {
    final result = await audioStore.stop();
    if (result == 1 && mounted) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = const Duration();
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }

  Widget currentIcon(MessagingModel model) {
    if (_isPlaying) {
      return IconButton(
        onPressed: _isPlaying ? () => _pause() : null,
        iconSize: 32.0,
        icon: const Icon(Icons.pause),
        color: Colors.white,
      );
    } else {
      return IconButton(
        onPressed: () async {
          if (_isPaused) {
            final result = await audioStore.resume();
            if (result == 1) setState(() => _playerState = PlayerState.playing);
          } else {
            await play(widget.attachment, model);
          }
        },
        iconSize: 32.0,
        icon: const Icon(Icons.play_arrow),
        color: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    model = context.watch<MessagingModel>();
    switch (widget.attachment.status) {
      case StoredAttachment_Status.PENDING_UPLOAD:
      case StoredAttachment_Status.PENDING:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline),
                const Text(
                  'Uploading',
                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                ),
              ],
            ),
          ],
        );
      case StoredAttachment_Status.FAILED:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline),
                const Text(
                  'Audio/File not available',
                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                ),
              ],
            ),
          ],
        );
      case StoredAttachment_Status.DONE:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                currentIcon(model!),
                Container(
                  width: MediaQuery.of(context).size.width * 0.75 - 70,
                  child: SliderTheme(
                    data: const SliderThemeData(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.grey,
                      thumbColor: Colors.blue,
                    ),
                    child: Slider(
                      onChanged: (v) {
                        final position = v * _duration!.inMilliseconds;
                        audioStore.audioPlayer.seek(
                          Duration(
                            milliseconds: position.round(),
                          ),
                        );
                      },
                      divisions: 100,
                      label: (_position != null &&
                              _duration != null &&
                              _position!.inMilliseconds > 0 &&
                              _position!.inMilliseconds <
                                  _duration!.inMilliseconds)
                          ? (_position!.inSeconds).toString() + ' sec.'
                          : '0 sec.',
                      value: (_position != null &&
                              _duration != null &&
                              _position!.inMilliseconds > 0 &&
                              _position!.inMilliseconds <
                                  _duration!.inMilliseconds)
                          ? _position!.inMilliseconds /
                              _duration!.inMilliseconds
                          : 0.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    _stop();
    audioStore.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _playerControlCommandSubscription?.cancel();
    super.dispose();
  }

  void initAudioPlayer() {
    _durationSubscription =
        audioStore.audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);

      // Implemented for iOS, waiting for android impl
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        // (Optional) listen for notification updates in the background
        audioStore.audioPlayer.startHeadlessService();

        // set at least title to see the notification bar on ios.
        audioStore.audioPlayer.setNotification(
          title: 'Lantern',
          duration: duration,
          elapsedTime: const Duration(seconds: 0),
          hasNextTrack: false,
          hasPreviousTrack: false,
        );
      }
    });

    _positionSubscription =
        audioStore.audioPlayer.onAudioPositionChanged.listen(
      (p) => setState(
        () => _position = p,
      ),
    );

    _playerCompleteSubscription =
        audioStore.audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription =
        audioStore.audioPlayer.onPlayerError.listen((msg) {
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = const Duration(seconds: 0);
        _position = const Duration(seconds: 0);
      });
    });

    /// if there's more audio
    _playerControlCommandSubscription =
        audioStore.audioPlayer.onPlayerCommand.listen((command) {
      print('command');
    });

    audioStore.audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlayerState = state;
      });
    });

    audioStore.audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _audioPlayerState = state);
    });
  }

  @override
  void didUpdateWidget(VoiceMemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    initAudioPlayer();
    _stop();
  }

  Future<int> play(StoredAttachment attachment, MessagingModel model) async {
    (_position != null &&
            _duration != null &&
            _position!.inMilliseconds > 0 &&
            _position!.inMilliseconds < _duration!.inMilliseconds)
        ? _position
        : null;
    final bytes = await model.decryptAttachment(attachment);
    await audioStore.stop();
    final result = await audioStore.audioPlayer.playBytes(bytes);

    if (result == 1) setState(() => _playerState = PlayerState.playing);
    // default playback rate is 1.0
    // this should be called after _audioPlayer.play() or _audioPlayer.resume()
    // this can also be called everytime the user wants to change playback rate in the UI
    await audioStore.audioPlayer.setPlaybackRate(playbackRate: 1.0);
    return result;
  }
}
