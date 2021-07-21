import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioStore {
  AudioPlayer audioPlayer = AudioPlayer();

  Icon currentIcon = const Icon(Icons.play_circle_filled);

  void playBytes(
      {required Uint8List bytes,
      bool stayAwake = false,
      Duration? position,
      double volume = 1.0}) {
    audioPlayer.playBytes(bytes,
        stayAwake: stayAwake, position: position, volume: volume);
  }

  Future<int> resume() async => await audioPlayer.resume();

  Future<int> pause() async => await audioPlayer.pause();

  Future<int> stop() async {
    var result = await audioPlayer.stop();
    return result;
  }

  Future<void> dispose() async => audioPlayer.dispose();
}
