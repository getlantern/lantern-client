import 'dart:async';
import 'dart:typed_data';

import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/audio.dart';
import 'package:loader_overlay/loader_overlay.dart';

enum PlayerState { stopped, playing, paused }

class AudioValue {
  Duration? duration;
  Duration? position;
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
    model = context.watch<MessagingModel>();
    audio = context.watch<Audio>();

    var milliseconds =
        (double.tryParse(attachment.attachment.metadata['duration']!)! * 1000)
            .toInt();
    value.duration = Duration(milliseconds: milliseconds);
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
