import 'dart:async';
import 'dart:typed_data';

import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/voice_recorder/slider_audio/rectangle_slider_thumb_shape.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/audio.dart';
import 'package:lantern/utils/waveform/wave_progress_bar.dart';
import 'package:lantern/utils/waveform_extension.dart';
import 'package:loader_overlay/loader_overlay.dart';

enum PlayerState { stopped, playing, paused }

class AudioValue {
  Duration? duration;
  Duration? position;
  var reducedAudioWave = <double>[];
  PlayerState playerState = PlayerState.stopped;

  bool get isPlaying => playerState == PlayerState.playing;

  bool get isPaused => playerState == PlayerState.paused;
}

class AudioController extends ValueNotifier<AudioValue> {
  final BuildContext context;
  final StoredAttachment attachment;
  late MessagingModel model;
  late Audio audio;

  AudioController(this.context, this.attachment) : super(AudioValue()) {
    model = Provider.of<MessagingModel>(context, listen: false);
    audio = Provider.of<Audio>(context, listen: false);

    var durationString = attachment.attachment.metadata['duration'];
    if (durationString != null) {
      var milliseconds = (double.tryParse(durationString)! * 1000).toInt();
      value.duration = Duration(milliseconds: milliseconds);
    }

    model.thumbnail(attachment).then((t) {
      value.reducedAudioWave =
          AudioWaveform.fromBuffer(t).bars.reducedWaveform();
      notifyListeners();
    });
  }

  Future<int> pause() async {
    final result = await audio.pause();
    if (result == 1) {
      value.playerState = PlayerState.paused;
      notifyListeners();
    }
    return result;
  }

  Future<int> stop() async {
    final result = await audio.stop();
    if (result == 1) {
      value.playerState = PlayerState.paused;
      value.position = const Duration();
      notifyListeners();
    }
    return result;
  }

  Future<void> seek(Duration position) async {
    await audio.seek(position);
  }

  Future<void> play() async {
    if (value.playerState == PlayerState.paused) {
      await _resume();
      return;
    }

    context.loaderOverlay.show();
    try {
      var bytes = await model.decryptAttachment(attachment);
      await _play(bytes);
    } finally {
      context.loaderOverlay.hide();
    }
  }

  Future<void> _play(Uint8List bytes) async {
    await audio.play(
      bytes: bytes,
      onAttached: () {
        value.playerState = PlayerState.playing;
        notifyListeners();
      },
      onDetached: () {
        value.playerState = PlayerState.stopped;
        notifyListeners();
      },
      onDurationChanged: ((d) {
        value.duration = d;
        notifyListeners();
      }),
      onPositionChanged: ((p) {
        value.position = p;
        notifyListeners();
      }),
    );
  }

  Future<void> _resume() async {
    if (await audio.resume() == 1) {
      value.playerState = PlayerState.playing;
      notifyListeners();
    }
  }
}

class AudioWidget extends StatelessWidget {
  final AudioController controller;
  final Color initialColor;
  final Color progressColor;
  final Color backgroundColor;
  final bool showTimeRemaining;
  final double waveHeight;
  final double width;

  AudioWidget(
      {required this.controller,
      required this.initialColor,
      required this.progressColor,
      required this.backgroundColor,
      this.showTimeRemaining = true,
      required this.waveHeight,
      required this.width});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: controller,
        builder: (BuildContext context, AudioValue value, Widget? child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      Container(
                          width: 40,
                          height: showTimeRemaining ? 80 : 40,
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: _getPlayIcon(controller, value)),
                      if (showTimeRemaining && value.duration != null)
                        _getDurationField(value),
                    ],
                  )
                ],
              ),
              Container(
                width: width,
                margin: const EdgeInsets.fromLTRB(0, 0, 15.0, 0),
                height: waveHeight,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    value.reducedAudioWave.isNotEmpty
                        ? _getWaveBar(
                            context, value, value.reducedAudioWave, width)
                        : const SizedBox(),
                    _getSliderOverlay(value, waveHeight),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget _getDurationField(AudioValue value) => Container(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
            (value.duration! - (value.position ?? const Duration()))
                .toString()
                .substring(2, 7),
            style: TextStyle(
                color: initialColor,
                fontWeight: FontWeight.w500,
                fontSize: 10.0)),
      );

  Positioned _getSliderOverlay(AudioValue value, double thumbShapeHeight) {
    return Positioned.fill(
      left: -22,
      top: 1,
      bottom: 0,
      right: -22,
      child: SliderTheme(
        data: SliderThemeData(
            activeTrackColor: value.reducedAudioWave.isNotEmpty
                ? Colors.transparent
                : Colors.grey,
            inactiveTrackColor: value.reducedAudioWave.isNotEmpty
                ? Colors.transparent
                : Colors.blue,
            valueIndicatorColor: Colors.grey.shade200,
            thumbShape: RectangleSliderThumbShapes(
                height: thumbShapeHeight,
                isPlaying: value.playerState == PlayerState.playing ||
                    value.playerState == PlayerState.paused)),
        child: Slider(
          onChanged: (v) {
            if (value.playerState == PlayerState.stopped) {
              // can't seek while stopped
              return;
            }
            final position = v * value.duration!.inMilliseconds;
            controller.seek(
              Duration(
                milliseconds: position.round(),
              ),
            );
          },
          label: (value.position != null &&
                  value.duration != null &&
                  value.position!.inMilliseconds > 0 &&
                  value.position!.inMilliseconds <
                      value.duration!.inMilliseconds)
              ? (value.position!.inSeconds).toString() + ' sec.'
              : '0 sec.',
          value: (value.position != null &&
                  value.duration != null &&
                  value.position!.inMilliseconds > 0 &&
                  value.position!.inMilliseconds <
                      value.duration!.inMilliseconds)
              ? value.position!.inMilliseconds / value.duration!.inMilliseconds
              : 0.0,
        ),
      ),
    );
  }

  Widget _getPlayIcon(AudioController controller, AudioValue value) {
    return value.isPlaying
        ? TextButton(
            onPressed: value.isPlaying ? () => controller.pause() : null,
            style: TextButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Colors.white,
                alignment: Alignment.center),
            child: const Icon(
              Icons.pause,
              color: Colors.black,
              size: 20.0,
            ),
          )
        : TextButton(
            onPressed: () async {
              await controller.play();
            },
            style: TextButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Colors.white,
                alignment: Alignment.center),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.black,
              size: 20.0,
            ),
          );
  }

  Widget _getWaveBar(BuildContext context, AudioValue value,
          List<double> reducedAudioWave, double width) =>
      WaveProgressBar(
        progressPercentage: (value.position != null &&
                value.duration != null &&
                value.position!.inMilliseconds > 0 &&
                value.position!.inMilliseconds < value.duration!.inMilliseconds)
            ? (value.position!.inMilliseconds /
                    value.duration!.inMilliseconds) *
                100
            : 0.0,
        alignment: Alignment.bottomCenter,
        listOfHeights: reducedAudioWave,
        width: width,
        initialColor: initialColor,
        progressColor: progressColor,
        backgroundColor: backgroundColor,
      );
}
