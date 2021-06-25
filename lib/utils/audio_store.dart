import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioStore {
  AudioPlayer audioPlayer = AudioPlayer();

  int indexPlaying = -1;

  Icon currentIcon = const Icon(Icons.play_circle_filled);

  void setCurrentIndex(int index) => indexPlaying = index;

  void play(String audioUrl, int indexPlay) {
    audioPlayer.play(audioUrl);
    indexPlaying = indexPlay;
    currentIcon = const Icon(Icons.stop_circle_outlined);
  }

  void playBytes(
      {required Uint8List bytes,
      required int indexPlay,
      bool stayAwake = false,
      Duration? position,
      double volume = 1.0}) {
    audioPlayer.playBytes(bytes,
        stayAwake: stayAwake, position: position, volume: volume);
    indexPlaying = indexPlay;
    currentIcon = const Icon(Icons.stop_circle_outlined);
  }

  Future<void> resume(Duration position) async {
    await audioPlayer.seek(position);
    await audioPlayer.resume();
  }

  void stop(int indexStop) {
    audioPlayer.stop();
    indexPlaying = indexStop;
    currentIcon = const Icon(Icons.play_circle_filled);
  }
}
