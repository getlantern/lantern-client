import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/attachment_types/voice.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/utils/audio_store.dart';
import 'package:lantern/package_store.dart';

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
            child: Container(
              height: 100.0,
              child: _getWaveBar(),
            ),
          ),
        ],
      ),
      trailing: currentIcon(),
    );
  }

  Widget currentIcon() {
    if (_isPlaying) {
      return TextButton(
        onPressed: _isPlaying ? () => _pause() : null,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.black),
          shape: MaterialStateProperty.all<CircleBorder>(
            const CircleBorder(),
          ),
        ),
        child: const Icon(
          Icons.pause,
          color: Colors.white,
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

  Widget _getWaveBar() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: 100,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        var _height = rand.nextInt(50).toDouble();
        return StreamBuilder<Duration>(
          stream: audioStore.audioPlayer.onAudioPositionChanged,
          initialData: const Duration(seconds: 0),
          builder: (context, snapshot) {
            return GestureDetector(
              onTap: () => audioStore.audioPlayer.seek(Duration(
                  seconds: (index * _duration!.inMilliseconds ~/ 10000))),
              child: Align(
                child: Container(
                  width: 2,
                  height: _height < 5 ? 5 : _height,
                  color:
                      index * ((_duration?.inMicroseconds ?? 100) / 100000) >=
                              (snapshot.data!.inSeconds)
                          ? Colors.black
                          : Colors.blue,
                ),
              ),
            );
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () => audioStore.audioPlayer.seek(
            Duration(
              seconds: (index * _duration!.inMilliseconds ~/ 100000),
            ),
          ),
          child: Align(
            child: Container(
              width: 2,
              height: 50,
              color: Colors.transparent,
            ),
          ),
        );
      },
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
    _durationSubscription =
        audioStore.audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _playerCompleteSubscription =
        audioStore.audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() => _position = _duration);
    });

    _playerErrorSubscription =
        audioStore.audioPlayer.onPlayerError.listen((msg) {
      //ERROR ON FORMAT (MAYBE IS DUE TO THE AUDIO BEEN ENCRYPTED)
      print("AUDIO ERROR: ${msg}");
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = const Duration(seconds: 0);
        _position = const Duration(seconds: 0);
      });
    });

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
    (_position != null &&
            _duration != null &&
            _position!.inMilliseconds > 0 &&
            _position!.inMilliseconds < _duration!.inMilliseconds)
        ? _position
        : null;

    var demoss = StoredAttachment.fromBuffer(widget.recording!);
    var variable = await model!.decryptAttachment(demoss);
    await audioStore.stop();
    final result = await audioStore.audioPlayer.playBytes(variable);
    if (result == 1) setState(() => _playerState = PlayerState.playing);
    await audioStore.audioPlayer.setPlaybackRate(playbackRate: 1.0);
    return result;
  }
}
