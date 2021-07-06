import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lantern/utils/audio_store.dart';

class WaveForm extends StatefulWidget {
  final Uint8List audio;
  final AudioStore audioStore;
  final bool isPlaying;

  const WaveForm({
    required this.isPlaying,
    required this.audio,
    required this.audioStore,
  });
  @override
  _WaveFormState createState() => _WaveFormState();
}

class _WaveFormState extends State<WaveForm> {
  // int _progressValue = 0;
  StreamSubscription? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  Duration? _duration;
  Duration? _position;
  var rand = Random();

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
    if (widget.isPlaying) {
      widget.audioStore.playBytes(bytes: widget.audio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(height: 100, child: _getWaveBar());
  }

  void initAudioPlayer() {
    _durationSubscription =
        widget.audioStore.audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _playerCompleteSubscription =
        widget.audioStore.audioPlayer.onPlayerCompletion.listen((event) {
      setState(() => _position = _duration);
    });

    // _playerErrorSubscription =
    //     audioStore.audioPlayer.onPlayerError.listen((msg) {
    //   setState(() {
    //     _playerState = PlayerState.stopped;
    //     _duration = const Duration(seconds: 0);
    //     _position = const Duration(seconds: 0);
    //   });
    // });

    widget.audioStore.audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
    });

    widget.audioStore.audioPlayer.onNotificationPlayerStateChanged
        .listen((state) {
      if (!mounted) return;
    });
  }

  Widget _getWaveBar() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: 100,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        var _height = rand.nextInt(50).toDouble();
        return StreamBuilder<Duration>(
          stream: widget.audioStore.audioPlayer.onAudioPositionChanged,
          initialData: const Duration(seconds: 0),
          builder: (context, snapshot) {
            return GestureDetector(
              onTap: () => widget.audioStore.audioPlayer.seek(Duration(
                  seconds: (index * _duration!.inMilliseconds ~/ 100000))),
              child: Align(
                child: Container(
                  width: 2,
                  height: _height < 5 ? 5 : _height,
                  color: index * ((_duration?.inSeconds ?? 100) / 100000) >=
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
          onTap: () => widget.audioStore.audioPlayer.seek(
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
}
