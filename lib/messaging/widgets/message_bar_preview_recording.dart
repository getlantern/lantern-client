import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lantern/messaging/widgets/slider_audio/rectangle_slider_thumb_shape.dart';
import 'package:lantern/utils/waveform/waveform.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/attachment_types/voice.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/utils/audio_store.dart';
import 'package:lantern/package_store.dart';
import 'package:pedantic/pedantic.dart';

class MessageBarPreviewRecording extends StatefulWidget {
  final Uint8List? recording;
  final VoidCallback onCancelRecording;

  const MessageBarPreviewRecording(
      {required this.recording, required this.onCancelRecording});

  @override
  State<StatefulWidget> createState() {
    return _MessageBarPreviewRecordingState();
  }
}

class _MessageBarPreviewRecordingState
    extends State<MessageBarPreviewRecording> {
  StreamSubscription? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerErrorSubscription;
  Duration? _duration;
  Duration? _position;
  PlayerState _playerState = PlayerState.stopped;
  AudioStore audioStore = AudioStore();
  bool get _isPlaying => _playerState == PlayerState.playing;
  bool get _isPaused => _playerState == PlayerState.paused;
  Random rand = Random();
  MessagingModel? model;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    model = context.watch<MessagingModel>();
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      leading: IconButton(
        onPressed: widget.onCancelRecording,
        icon: const Icon(
          Icons.close_rounded,
          color: Colors.black,
          size: 30.0,
        ),
      ),
      title: Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: Stack(
              clipBehavior: Clip.antiAlias,
              children: [
                Positioned(
                  top: 1,
                  left: 1,
                  height: 100,
                  width: 270,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: _getWaveBar(),
                  ),
                ),
                Positioned.fill(
                  left: -22,
                  top: 1,
                  bottom: 10,
                  right: -22,
                  child: SliderTheme(
                    data: const SliderThemeData(
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      thumbShape: RectangleSliderThumbShapes(height: 35),
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
          ),
        ],
      ),
      trailing: currentIcon(),
    );
  }

  double moveTo() {
    var percentageAudio =
        (_position!.inMilliseconds * 100) / (_duration!.inMilliseconds);
    return (270 * percentageAudio * 0.01);
  }

  Widget currentIcon() {
    if (_isPlaying) {
      return TextButton(
        onPressed: _isPlaying ? () => _pause() : null,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Colors.grey[200],
          ),
          shape: MaterialStateProperty.all<CircleBorder>(
            const CircleBorder(),
          ),
        ),
        child: const Icon(
          Icons.pause,
          color: Colors.black,
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
            await play();
          }
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.black),
          shape: MaterialStateProperty.all<CircleBorder>(
            const CircleBorder(),
          ),
        ),
        child: const Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: 20.0,
        ),
      );
    }
  }

  Widget _getWaveBar() => FutureBuilder(
        future: model!
            .decryptAttachment(StoredAttachment.fromBuffer(widget.recording!)),
        builder: (context, AsyncSnapshot<Uint8List>? snapshot) {
          return (snapshot != null && snapshot.hasData)
              ? CustomPaint(
                  painter: Waveform(
                    waveData: snapshot.data!,
                    gap: 1,
                    density: 130,
                    height: 100,
                    width: 270,
                    startingHeight: 5,
                    finishedHeight: 5.5,
                    color: Colors.black,
                  ),
                )
              : const SizedBox();
        },
      );

  @override
  void dispose() {
    _stop();
    audioStore.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    super.dispose();
  }

  void initAudioPlayer() {
    _durationSubscription = audioStore.audioPlayer.onDurationChanged
        .listen((duration) => setState(() => _duration = duration));

    _playerCompleteSubscription =
        audioStore.audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() => _position = _duration);
    });

    _playerErrorSubscription =
        audioStore.audioPlayer.onPlayerError.listen((msg) {
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = const Duration(seconds: 0);
        _position = const Duration(seconds: 0);
      });
    });

    _positionSubscription =
        audioStore.audioPlayer.onAudioPositionChanged.listen(
      (p) => setState(
        () => _position = p,
      ),
    );

    audioStore.audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
    });
    unawaited(Future.microtask(() async {
      await play();
      await _pause();
    }));
  }

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

  void _onComplete() => setState(() => _playerState = PlayerState.stopped);

  Future<int> play() async {
    (_position != null &&
            _duration != null &&
            _position!.inMilliseconds > 0 &&
            _position!.inMilliseconds < _duration!.inMilliseconds)
        ? _position
        : null;

    var _storedAttachment = StoredAttachment.fromBuffer(widget.recording!);
    var bytes = await model!.decryptAttachment(_storedAttachment);
    await audioStore.stop();
    final result = await audioStore.audioPlayer.playBytes(bytes);
    if (result == 1) setState(() => _playerState = PlayerState.playing);
    await audioStore.audioPlayer.setPlaybackRate(playbackRate: 1.0);
    return result;
  }
}
