import 'package:lantern/features/messaging/conversation/audio/rectangle_slider_thumb_shape.dart';
import 'package:lantern/features/messaging/conversation/audio/waveform.dart';
import 'package:lantern/features/messaging/messaging.dart';

enum PlayerState { stopped, playing, paused }

class AudioValue {
  Duration? duration;
  Duration? realDuration;
  Duration? position;
  int? pendingPercentage;
  var bars = List<int>.empty();
  PlayerState playerState = PlayerState.stopped;

  bool get isPlaying => playerState == PlayerState.playing;

  bool get isPaused => playerState == PlayerState.paused;
}

// (crdzbird): For some reason we have 2 different final times.
//2887: is from the thumbnail or decrypted audio.
//2388: is the final time from the audio.
// 2594: is the final time from the audio using audioplayers.
// When we start the player, we always receive a progress percentage below 100%.
// the missing difference is obtained from the thumbnail `2887` and the final time `2594`.
// once we have that time difference we can override the thumbnail time with the new final time.

int percentageOf(int value, int maxValue) =>
    (100 - (((value) / maxValue) * 100)).toInt();

class AudioController extends ValueNotifier<AudioValue> {
  final BuildContext context;
  final StoredAttachment attachment;

  AudioController({
    required this.context,
    required this.attachment,
    Uint8List? thumbnail,
  }) : super(AudioValue()) {
    var durationString = attachment.attachment.metadata['duration'];
    if (durationString != null) {
      var milliseconds = (double.tryParse(durationString)! * 1000).toInt();
      value.duration = Duration(milliseconds: milliseconds);
      value.realDuration = Duration(milliseconds: milliseconds);
      value.pendingPercentage = 0;
    }

    var thumbnailFuture = thumbnail != null
        ? Future.value(thumbnail)
        : messagingModel.thumbnail(attachment).value.future;
    thumbnailFuture.then((t) {
      value.bars = AudioWaveform.fromBuffer(t).bars;
      notifyListeners();
    });
  }

  Future<void> pause() async {
    await audio.pause();
    value.playerState = PlayerState.paused;
    notifyListeners();
  }

  Future<void> stop() async {
    await audio.stop();
    value.playerState = PlayerState.paused;
    value.position = const Duration();
    value.realDuration = const Duration();
    value.pendingPercentage = 0;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await audio.seek(position);
  }

  Future<void> play() async {
    if (value.playerState == PlayerState.paused) {
      await _resume();
      return;
    }

    context.loaderOverlay.show(widget: spinner);
    try {
      var bytes = await messagingModel.decryptAttachment(attachment);
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
        value.position = const Duration(); // reset position to start
        notifyListeners();
      },
      onDurationChanged: ((d) {
        value.realDuration = d;
        value.pendingPercentage =
            percentageOf(d.inMilliseconds, value.duration!.inMilliseconds);
        notifyListeners();
      }),
      onPositionChanged: ((p) {
        value.position = p;
        notifyListeners();
      }),
    );
  }

  Future<void> _resume() async {
    await audio.resume();
    value.playerState = PlayerState.playing;
    notifyListeners();
  }
}

class AudioWidget extends StatelessWidget {
  static const height = 24.0;

  final AudioController controller;
  final Color initialColor;
  final Color progressColor;
  final CrossAxisAlignment? timeRemainingAlignment;

  AudioWidget({
    required this.controller,
    required this.initialColor,
    required this.progressColor,
    this.timeRemainingAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (BuildContext context, AudioValue value, Widget? child) {
        if (timeRemainingAlignment != null) {
          return Column(
            crossAxisAlignment: timeRemainingAlignment!,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 4),
                child: _buildWaveformRow(value),
              ),
              _getTimeRemaining(value),
            ],
          );
        } else {
          return _buildWaveformRow(value);
        }
      },
    );
  }

  Widget _buildWaveformRow(AudioValue value) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          // Always force LTR direction since we're talking about the passage
          // of time.
          textDirection: TextDirection.ltr,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PlayButton(
              size: height,
              color: initialColor,
              playing: value.isPlaying,
              onPressed: () async {
                unawaited(HapticFeedback.lightImpact());
                if (value.isPlaying) {
                  await controller.pause();
                } else {
                  await controller.play();
                }
              },
            ),
            Container(width: 12),
            Container(
              width: constraints.maxWidth - 36,
              height: height,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  value.bars.isNotEmpty
                      ? _getWaveform(
                          context,
                          value,
                          value.bars,
                          constraints.maxWidth - 36,
                        )
                      : const SizedBox(),
                  _getSliderOverlay(context, value),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _getTimeRemaining(AudioValue value) => Container(
        padding: const EdgeInsetsDirectional.only(bottom: 6.0, top: 2.0),
        child: CText(
          (value.duration! - (value.position ?? const Duration()))
              .toString()
              .substring(2, 7),
          style: CTextStyle(
            color: initialColor,
            fontSize: 10.0,
            lineHeight: 16,
          ),
        ),
      );

  Widget _getSliderOverlay(BuildContext context, AudioValue value) {
    var _progress = _updateProgress(value);
    return Align(
      alignment: Alignment.bottomCenter,
      child: mirrorLTR(
        context: context,
        child: SliderTheme(
          data: SliderThemeData(
            trackHeight: 0,
            activeTrackColor: value.bars.isNotEmpty ? transparent : Colors.grey,
            inactiveTrackColor:
                value.bars.isNotEmpty ? transparent : Colors.blue,
            valueIndicatorColor: Colors.grey.shade200,
            trackShape: CustomTrackShape(),
            thumbShape: RectangleSliderThumbShapes(
              height: height,
              isPlaying: value.playerState == PlayerState.playing ||
                  value.playerState == PlayerState.paused,
            ),
          ),
          child: Slider(
            onChanged: (v) {
              if (value.playerState == PlayerState.stopped) {
                // can't seek while stopped
                return;
              }
              final position = v * value.duration!.inMilliseconds / 100;
              controller.seek(
                Duration(
                  milliseconds: position.round(),
                ),
              );
            },
            min: 0,
            max: 100,
            value: _progress,
          ),
        ),
      ),
    );
  }

  Widget _getWaveform(
    BuildContext context,
    AudioValue value,
    List<int> bars,
    double width,
  ) {
    var _progress = _updateProgress(value);
    return Waveform(
      progressPercentage: _progress,
      bars: bars,
      initialColor: initialColor,
      progressColor: progressColor,
      width: width,
      height: height,
    );
  }

  double _updateProgress(AudioValue value) {
    var _progress = 0.0;
    if (value.position != null &&
        value.realDuration != null &&
        value.pendingPercentage != null &&
        value.position!.inMilliseconds > 0 &&
        value.position!.inMilliseconds < value.realDuration!.inMilliseconds) {
      _progress = (value.position!.inMilliseconds /
                      value.realDuration!.inMilliseconds) *
                  (100 + value.pendingPercentage!) >
              100
          ? 100
          : (value.position!.inMilliseconds /
                  value.realDuration!.inMilliseconds) *
              (100 + value.pendingPercentage!);
    }
    return _progress;
  }
}
