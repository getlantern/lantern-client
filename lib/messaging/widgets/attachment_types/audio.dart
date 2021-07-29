import 'dart:typed_data';

import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/audio_widget.dart';
import 'package:lantern/messaging/widgets/slider_audio/rectangle_slider_thumb_shape.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/duration_extension.dart';
import 'package:lantern/utils/waveform/wave_progress_bar.dart';
import 'package:lantern/utils/waveform_extension.dart';
import 'package:sizer/sizer.dart';

/// An attachment that shows an audio player.
class AudioAttachment extends StatelessWidget {
  final StoredAttachment attachment;
  final bool inbound;

  AudioAttachment(this.attachment, this.inbound);

  Widget currentIcon(AudioController controller, AudioValue value) {
    if (value.isPlaying) {
      return TextButton(
        onPressed: value.isPlaying ? () => controller.pause() : null,
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
          await controller.play();
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
    final model = context.watch<MessagingModel>();

    switch (attachment.status) {
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
                  color: inbound ? inboundMsgColor : outboundMsgColor,
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
        AudioController controller = AudioController(context, attachment);
        return FutureBuilder(
            future: model.thumbnail(attachment),
            builder: (context, AsyncSnapshot<Uint8List?>? snapshot) {
              if (snapshot == null || !snapshot.hasData) {
                return const SizedBox();
              }
              var reducedAudioWave = AudioWaveform.fromBuffer(snapshot.data!)
                  .bars
                  .reducedWaveform();
              return ValueListenableBuilder(
                  valueListenable: controller,
                  builder:
                      (BuildContext context, AudioValue value, Widget? child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            currentIcon(controller, value),
                            Text(
                              value.playerState == PlayerState.stopped
                                  ? value.duration!
                                      .time(minute: true, seconds: true)
                                  : value.duration!
                                      .calculate(inputDuration: value.position)
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
                                  ? _getWaveBar(
                                      context, value, reducedAudioWave)
                                  : const SizedBox(),
                              Positioned.fill(
                                left: -22,
                                top: 1,
                                bottom: 10,
                                right: -22,
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor:
                                        reducedAudioWave.isNotEmpty
                                            ? Colors.transparent
                                            : Colors.grey,
                                    inactiveTrackColor:
                                        reducedAudioWave.isNotEmpty
                                            ? Colors.transparent
                                            : Colors.blue,
                                    valueIndicatorColor: Colors.grey.shade200,
                                    thumbShape:
                                        const RectangleSliderThumbShapes(
                                            height: 45),
                                  ),
                                  child: Slider(
                                    onChanged: (v) {
                                      if (value.playerState ==
                                          PlayerState.stopped) {
                                        // can't seek while stopped
                                        return;
                                      }
                                      final position =
                                          v * value.duration!.inMilliseconds;
                                      controller.seek(
                                        Duration(
                                          milliseconds: position.round(),
                                        ),
                                      );
                                    },
                                    label: (value.position != null &&
                                            value.duration != null &&
                                            value.position!.inMilliseconds >
                                                0 &&
                                            value.position!.inMilliseconds <
                                                value.duration!.inMilliseconds)
                                        ? (value.position!.inSeconds)
                                                .toString() +
                                            ' sec.'
                                        : '0 sec.',
                                    value: (value.position != null &&
                                            value.duration != null &&
                                            value.position!.inMilliseconds >
                                                0 &&
                                            value.position!.inMilliseconds <
                                                value.duration!.inMilliseconds)
                                        ? value.position!.inMilliseconds /
                                            value.duration!.inMilliseconds
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
            });
      default:
        return const SizedBox();
    }
  }

  Widget _getWaveBar(BuildContext context, AudioValue value,
          List<double> reducedAudioWave) =>
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
        width: MediaQuery.of(context).size.width * 0.6,
        initalColor: inbound ? Colors.black : Colors.white,
        progressColor: inbound ? outboundMsgColor : inboundMsgColor,
        backgroundColor: inbound ? inboundBgColor : outboundBgColor,
      );
}
