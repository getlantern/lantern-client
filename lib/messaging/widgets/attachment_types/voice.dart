import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/notifications.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/slider_audio/rectangle_slider_thumb_shape.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/audio_store.dart';
import 'package:lantern/utils/duration_extension.dart';
import 'package:lantern/utils/waveform/wave_progress_bar.dart';
import 'package:lantern/utils/waveform_extension.dart';
import 'package:sizer/sizer.dart';

/// An attachment that shows an audio player.
enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class VoiceMemo extends StatefulWidget {
  final StoredAttachment attachment;
  final bool inbound;

  VoiceMemo(this.attachment, this.inbound);

  @override
  State<StatefulWidget> createState() {
    return VoiceMemoState();
  }
}

class VoiceMemoState extends State<VoiceMemo> {
  AudioStore audioStore = AudioStore();
  MessagingModel? model;
  Duration? _duration;
  Duration? _position;
  AudioWaveform? _waveform;
  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerErrorSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription<PlayerControlCommand>? _playerControlCommandSubscription;
  bool get _isPlaying => _playerState == PlayerState.playing;
  bool get _isPaused => _playerState == PlayerState.paused;
  List<double> reducedAudioWave = [];

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

  Widget currentIcon(MessagingModel model, Uint8List bytes) {
    if (_isPlaying) {
      return TextButton(
        onPressed: _isPlaying ? () => _pause() : null,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Colors.white,
          ),
          shape: MaterialStateProperty.all<CircleBorder>(
            const CircleBorder(),
          ),
        ),
        child: Icon(
          Icons.pause,
          color: outboundBgColor,
          size: 20.0,
        ),
      );
    } else {
      return TextButton(
        onPressed: () async {
          if (_isPaused) {
            final result = await audioStore.resume();
            if (result == 1) setState(() => _playerState = PlayerState.playing);
          } else {
            await play(bytes);
          }
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all<CircleBorder>(
            const CircleBorder(),
          ),
        ),
        child: Icon(
          Icons.play_arrow,
          color: outboundBgColor,
          size: 20.0,
        ),
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
                CircularProgressIndicator(
                  strokeWidth: 0.5,
                  color: widget.inbound ? inboundMsgColor : outboundMsgColor,
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
        return FutureBuilder(
            future: loadData(),
            builder: (context, AsyncSnapshot<Uint8List?>? snapshot) {
              var _seconds = (double.tryParse(
                          widget.attachment.attachment.metadata['duration']!)! *
                      1000)
                  .toInt();
              var _audioDuration = Duration(milliseconds: _seconds);
              return snapshot != null && snapshot.hasData
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            currentIcon(model!, snapshot.data!),
                            Text(
                              _playerState == PlayerState.stopped
                                  ? _audioDuration.time(
                                      minute: true, seconds: true)
                                  : _audioDuration
                                      .calculate(inputDuration: _position)
                                      .time(minute: true, seconds: true),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.75 - 90,
                          padding: const EdgeInsets.only(top: 10),
                          height: 50,
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              _getWaveBar(),
                              Positioned.fill(
                                left: -22,
                                top: 1,
                                bottom: 10,
                                right: -22,
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor: Colors.transparent,
                                    inactiveTrackColor: Colors.transparent,
                                    valueIndicatorColor: Colors.grey.shade200,
                                    thumbShape:
                                        const RectangleSliderThumbShapes(
                                            height: 45),
                                  ),
                                  child: Slider(
                                    onChanged: (v) {
                                      final position =
                                          v * _duration!.inMilliseconds;
                                      audioStore.audioPlayer.seek(
                                        Duration(
                                          milliseconds: position.round(),
                                        ),
                                      );
                                    },
                                    label: (_position != null &&
                                            _duration != null &&
                                            _position!.inMilliseconds > 0 &&
                                            _position!.inMilliseconds <
                                                _duration!.inMilliseconds)
                                        ? (_position!.inSeconds).toString() +
                                            ' sec.'
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
                        ),
                      ],
                    )
                  : const SizedBox();
            });
      default:
        return const SizedBox();
    }
  }

  Future<Uint8List> loadData() async {
    var _bytesBuffer = await model!.thumbnail(widget.attachment);
    _waveform = AudioWaveform.fromBuffer(_bytesBuffer);
    reducedAudioWave =
        _waveform!.bars.map((e) => e.toDouble()).toList().reduceList(10);
    return await model!.decryptAttachment(widget.attachment);
  }

  Widget _getWaveBar() => WaveProgressBar(
        progressPercentage: (_position != null &&
                _duration != null &&
                _position!.inMilliseconds > 0 &&
                _position!.inMilliseconds < _duration!.inMilliseconds)
            ? (_position!.inMilliseconds / _duration!.inMilliseconds) * 100
            : 0.0,
        alignment: Alignment.bottomCenter,
        listOfHeights: reducedAudioWave,
        width: MediaQuery.of(context).size.width * 0.75 - 90,
        initalColor: widget.inbound ? Colors.black : Colors.white,
        progressColor: widget.inbound ? outboundMsgColor : inboundMsgColor,
        backgroundColor: widget.inbound ? inboundBgColor : outboundBgColor,
      );

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
        audioStore.audioPlayer.notificationService.startHeadlessService();

        // set at least title to see the notification bar on ios.
        audioStore.audioPlayer.notificationService.setNotification(
          title: 'Lantern',
          duration: duration,
          elapsedTime: const Duration(seconds: 0),
          enableNextTrackButton: false,
          enablePreviousTrackButton: false,
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

    audioStore.audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
    });

    audioStore.audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (!mounted) return;
    });
  }

  @override
  void didUpdateWidget(VoiceMemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    initAudioPlayer();
    //_stop();
  }

  Future<int> play(Uint8List bytes) async {
    (_position != null &&
            _duration != null &&
            _position!.inMilliseconds > 0 &&
            _position!.inMilliseconds < _duration!.inMilliseconds)
        ? _position
        : null;
    await audioStore.stop();
    final result = await audioStore.audioPlayer.playBytes(bytes);

    if (result == 1) setState(() => _playerState = PlayerState.playing);
    await audioStore.audioPlayer.setPlaybackRate(playbackRate: 1.0);
    return result;
  }
}
