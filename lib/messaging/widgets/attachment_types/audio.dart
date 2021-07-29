import 'dart:async';
import 'dart:typed_data';

import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/slider_audio/rectangle_slider_thumb_shape.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/audio.dart';
import 'package:lantern/utils/duration_extension.dart';
import 'package:lantern/utils/waveform/wave_progress_bar.dart';
import 'package:lantern/utils/waveform_extension.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

/// An attachment that shows an audio player.
enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class AudioAttachment extends StatefulWidget {
  final StoredAttachment attachment;
  final bool inbound;

  AudioAttachment(this.attachment, this.inbound);

  @override
  State<StatefulWidget> createState() {
    return AudioAttachmentState();
  }
}

class AudioAttachmentState extends State<AudioAttachment> {
  late MessagingModel model;
  late Audio audio;
  Duration? _duration;
  Duration? _position;
  PlayerState _playerState = PlayerState.stopped;

  bool get _isPlaying => _playerState == PlayerState.playing;

  bool get _isPaused => _playerState == PlayerState.paused;

  Future<int> _pause() async {
    final result = await audio.pause();
    if (result == 1) {
      setState(() => _playerState = PlayerState.paused);
    }
    return result;
  }

  Future<int> _stop() async {
    final result = await audio.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = const Duration();
      });
    }
    return result;
  }

  Widget currentIcon(MessagingModel model) {
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
            final result = await audio.resume();
            if (result == 1) setState(() => _playerState = PlayerState.playing);
          } else {
            context.loaderOverlay.show();
            try {
              var bytes = await model.decryptAttachment(widget.attachment);
              await play(bytes);
            } finally {
              context.loaderOverlay.hide();
            }
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
    audio = context.watch<Audio>();
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
            future: model.thumbnail(widget.attachment),
            builder: (context, AsyncSnapshot<Uint8List?>? snapshot) {
              var seconds = (double.tryParse(
                          widget.attachment.attachment.metadata['duration']!)! *
                      1000)
                  .toInt();
              var audioDuration = Duration(milliseconds: seconds);
              if (snapshot == null || !snapshot.hasData) {
                return const SizedBox();
              }
              var reducedAudioWave = AudioWaveform.fromBuffer(snapshot.data!)
                  .bars
                  .reducedWaveform();
              return Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      currentIcon(model),
                      Text(
                        _playerState == PlayerState.stopped
                            ? audioDuration.time(minute: true, seconds: true)
                            : audioDuration
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
                    width: MediaQuery.of(context).size.width * 0.6,
                    padding: const EdgeInsets.only(top: 10),
                    height: 50,
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        reducedAudioWave.isNotEmpty
                            ? _getWaveBar(reducedAudioWave)
                            : const SizedBox(),
                        Positioned.fill(
                          left: -22,
                          top: 1,
                          bottom: 10,
                          right: -22,
                          child: SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: reducedAudioWave.isNotEmpty
                                  ? Colors.transparent
                                  : Colors.grey,
                              inactiveTrackColor: reducedAudioWave.isNotEmpty
                                  ? Colors.transparent
                                  : Colors.blue,
                              valueIndicatorColor: Colors.grey.shade200,
                              thumbShape:
                                  const RectangleSliderThumbShapes(height: 45),
                            ),
                            child: Slider(
                              onChanged: (v) {
                                if (_playerState == PlayerState.stopped) {
                                  // can't seek while stopped
                                  return;
                                }
                                final position = v * _duration!.inMilliseconds;
                                audio.seek(
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            });
      default:
        return const SizedBox();
    }
  }

  Widget _getWaveBar(List<double> reducedAudioWave) => WaveProgressBar(
        progressPercentage: (_position != null &&
                _duration != null &&
                _position!.inMilliseconds > 0 &&
                _position!.inMilliseconds < _duration!.inMilliseconds)
            ? (_position!.inMilliseconds / _duration!.inMilliseconds) * 100
            : 0.0,
        alignment: Alignment.bottomCenter,
        listOfHeights: reducedAudioWave,
        width: MediaQuery.of(context).size.width * 0.6,
        initalColor: widget.inbound ? Colors.black : Colors.white,
        progressColor: widget.inbound ? outboundMsgColor : inboundMsgColor,
        backgroundColor: widget.inbound ? inboundBgColor : outboundBgColor,
      );

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  Future<void> play(Uint8List bytes) async {
    await audio.play(
      bytes: bytes,
      onAttached: () {
        setState(() {
          _playerState = PlayerState.playing;
        });
      },
      onDetached: () {
        setState(() {
          _playerState = PlayerState.stopped;
          _position = const Duration();
        });
      },
      onDurationChanged: ((d) => setState(() {
            _duration = d;
          })),
      onPositionChanged: ((p) => setState(() {
            _position = p;
          })),
    );
  }
}
