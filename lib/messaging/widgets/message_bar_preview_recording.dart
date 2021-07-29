import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/attachment_types/audio.dart';
import 'package:lantern/messaging/widgets/slider_audio/rectangle_slider_thumb_shape.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/audio_store.dart';
import 'package:lantern/utils/waveform/wave_progress_bar.dart';
import 'package:lantern/utils/waveform_extension.dart';
import 'package:sizer/sizer.dart';

class MessageBarPreviewRecording extends StatefulWidget {
  final MessagingModel model;
  final StoredAttachment recording;
  final VoidCallback onCancelRecording;
  final VoidCallback? onSend;

  const MessageBarPreviewRecording(
      {required this.model,
      required this.recording,
      required this.onCancelRecording,
      required this.onSend});

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
  var reducedAudioWave = <double>[];

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
    widget.model.thumbnail(widget.recording).then((thumbnail) {
      setState(() {
        reducedAudioWave =
            AudioWaveform.fromBuffer(thumbnail).bars.reducedWaveform();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      leading: currentIcon(),
      title: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: AlignmentDirectional.bottomStart,
        children: [
          _getWaveBar(context),
          Positioned.fill(
            right: MediaQuery.of(context).orientation == Orientation.landscape
                ? -135
                : -80,
            left: -23,
            child: _isPlaying || _isPaused
                ? SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: reducedAudioWave.isNotEmpty
                          ? Colors.transparent
                          : Colors.grey,
                      inactiveTrackColor: reducedAudioWave.isNotEmpty
                          ? Colors.transparent
                          : Colors.blue,
                      thumbShape:
                          const RectangleSliderThumbShapes(height: 41.5),
                      valueIndicatorColor: Colors.transparent,
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
                  )
                : const SizedBox(),
          ),
        ],
      ),
      trailing: Flex(
          mainAxisSize: MainAxisSize.min,
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: GestureDetector(
                onTap: widget.onCancelRecording,
                child: Icon(
                  Icons.delete,
                  color: Colors.black,
                  size: 20.sp,
                ),
              ),
            ),
            const VerticalDivider(color: Colors.transparent),
            Flexible(
              child: GestureDetector(
                onTap: widget.onSend,
                child: Icon(
                  Icons.send,
                  color: Colors.black,
                  size: 20.sp,
                ),
              ),
            ),
          ]),
    );
  }

  Widget currentIcon() {
    if (_isPlaying) {
      return GestureDetector(
        onTap: _isPlaying ? () => _pause() : null,
        child: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: const Icon(
            Icons.pause,
            color: Colors.black,
            size: 20.0,
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () async {
          if (_isPaused) {
            final result = await audioStore.resume();
            if (result == 1) setState(() => _playerState = PlayerState.playing);
          } else {
            await play();
          }
        },
        child: const CircleAvatar(
          backgroundColor: Colors.black,
          child: Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 20.0,
          ),
        ),
      );
    }
  }

  Widget _getWaveBar(BuildContext context) {
    if (reducedAudioWave.isEmpty) {
      return const SizedBox();
    }

    return WaveProgressBar(
      progressPercentage: (_position != null &&
              _duration != null &&
              _position!.inMilliseconds > 0 &&
              _position!.inMilliseconds < _duration!.inMilliseconds)
          ? (_position!.inMilliseconds / _duration!.inMilliseconds) * 120
          : 0.0,
      alignment: Alignment.bottomCenter,
      listOfHeights: reducedAudioWave,
      width: MediaQuery.of(context).size.width * 0.6,
      initalColor: Colors.black,
      progressColor: outboundMsgColor,
      backgroundColor: inboundBgColor,
    );
  }

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
    var bytes = await widget.model.decryptAttachment(widget.recording);
    await audioStore.stop();
    final result = await audioStore.audioPlayer.playBytes(bytes);
    if (result == 1) setState(() => _playerState = PlayerState.playing);
    await audioStore.audioPlayer.setPlaybackRate(playbackRate: 1.0);
    return result;
  }
}
