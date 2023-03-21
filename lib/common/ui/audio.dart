import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:mime/mime.dart';

final audio = Audio();

/// Provides a facility for playing back audio using a singleton AudioPlayer.
class Audio {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Function()? _onDetached;
  late Function(Duration) _onDurationChanged;
  late Function(Duration) _onPositionChanged;

  Audio() {
    _audioPlayer.onDurationChanged.listen((d) {
      _onDurationChanged(d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      _onPositionChanged(p);
    });

    _audioPlayer.onPlayerComplete.listen((e) {
      _onDetachedIfAvailable();
    });
  }

  /// Plays the audio in the given bytes.
  ///
  /// onAttached - called once playback successfully starts
  /// onDetached - called when playback ends or another widget uses this Audio
  ///              to start playing its own audio
  /// onDurationChanged - called when duration is updated (i.e. when playback starts)
  /// onPositionChanged - called as playback progresses
  Future<void> play({
    required Uint8List bytes,
    required Function() onAttached,
    required Function() onDetached,
    required Function(Duration) onDurationChanged,
    required Function(Duration) onPositionChanged,
  }) async {
    // detach previously connected consumer
    _onDetachedIfAvailable();
    _onDurationChanged = onDurationChanged;
    _onPositionChanged = onPositionChanged;
    _onDetached = onDetached;
    // defaults to having the mime-type application/octet-stream
    final mime = lookupMimeType('', headerBytes: bytes) ?? "application/octet-stream";
    await _audioPlayer.play(UrlSource(Uri.dataFromBytes(bytes, mimeType: mime).toString()));
    onAttached();
  }

  void _onDetachedIfAvailable() {
    if (_onDetached != null) {
      try {
        _onDetached!();
      } catch (e) {
        // ignore
      } finally {
        _onDetached = null;
      }
    }
  }

  Future<void> seek(Duration position) async =>
      await _audioPlayer.seek(position);

  Future<void> resume() async => await _audioPlayer.resume();

  Future<void> pause() async => await _audioPlayer.pause();

  Future<void> stop() async {
    var result = await _audioPlayer.stop();
    _onDetachedIfAvailable();
    return result;
  }
}
