import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/logic/common.dart';
import 'package:lantern/replica/models/replica_link.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:lantern/replica/ui/common.dart';
import 'package:lantern/replica/ui/media_views/playback_button.dart';
import 'package:logger/logger.dart';
import 'package:video_player/video_player.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

/// ReplicaVideoPlayerScreen takes a 'replicaLink' of a video and attempts to
/// stream it. If it can't stream the link, it'll show an error screen.
///
/// Example:
///
///   ReplicaVideoPlayerScreen(
///     replicaLink:
///       ReplicaLink.New('magnet%3A%3Fxt%3Durn%3Abtih%3A638f6f674c06a05f4cb4e45871beba10ad57818c%26so%3D0'))
///
class ReplicaVideoPlayerScreen extends StatefulWidget {
  ReplicaVideoPlayerScreen({Key? key, required this.replicaLink, this.mimeType})
      : super(key: key);
  final ReplicaLink replicaLink;
  final String? mimeType;

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<ReplicaVideoPlayerScreen> {
  bool _playbackControlsVisible = false;
  bool get _isPlaying => _videoController.value.isPlaying;
  Duration _totalDuration = const Duration(seconds: 0);
  Duration _position = const Duration(seconds: 0);
  final ReplicaApi _replicaApi =
      ReplicaApi(ReplicaCommon.getReplicaServerAddr()!);
  final _defaultSeekDurationInSeconds = 3;
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    // XXX <10-11-21, soltzen> Failures for this call are handled after the
    // future returned in the 'build()' function (see
    // _videoController.value.hasError usage in FutureBuilder)
    _videoController = VideoPlayerController.network(
        _replicaApi.getViewAddr(widget.replicaLink));
    _initializeVideoPlayerFuture = _videoController.initialize();

    // Add a listener for video playback changes
    _videoController.addListener(() {
      if (!_videoController.value.isPlaying) {
        return;
      }
      if (mounted) {
        setState(() {
          _position = _videoController.value.position;
          if (_videoController.value.duration != _totalDuration) {
            _totalDuration = _videoController.value.duration;
          }
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(
        context,
        _replicaApi,
        widget.replicaLink,
        SearchCategory.Video,
        widget.mimeType,
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          // If not done, show progress indicator
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // If error, show error with text
          if (_videoController.value.hasError || snapshot.hasError) {
            logger.e(
                'Received a playback error: ${_videoController.value.errorDescription ?? snapshot.error}');
            return Center(
                child: CText(
              'Encountered an error rendering the video. Please try again later'
                  .i18n,
              style: tsBody2,
            ));
          }

          // Else, render video
          return AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: Stack(children: [
              GestureDetector(
                  onTap: () {
                    setState(() {
                      _playbackControlsVisible = !_playbackControlsVisible;
                    });
                  },
                  child: VideoPlayer(_videoController)),
              AnimatedOpacity(
                opacity: _playbackControlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: white,
                              ),
                              color: white.withOpacity(0.5),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20))),
                          height: 120.0,
                          width: double.infinity,
                          child: Column(
                            children: [
                              renderPlaybackSlider(),
                              renderPlaybackButtons()
                            ],
                          ),
                        ))),
              )
            ]),
          );
        },
      ),
    );
  }

  Widget renderPlaybackButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlaybackButton(
          onTap: () async {
            _position = Duration(
                seconds:
                    max(0, _position.inSeconds - _defaultSeekDurationInSeconds)
                        .round());
            await _videoController.seekTo(_position);
          },
          path: ImagePaths.fast_rewind,
          size: 40,
        ),
        const SizedBox(width: 20),
        PlaybackButton(
          onTap: () async {
            _isPlaying
                ? await _videoController.pause()
                : await _videoController.play();
          },
          path: _isPlaying ? ImagePaths.pause : ImagePaths.play,
          size: 60,
        ),
        const SizedBox(width: 20),

        // Fast forward button
        PlaybackButton(
          onTap: () async {
            _position = Duration(
                seconds: min(_totalDuration.inSeconds,
                        _position.inSeconds + _defaultSeekDurationInSeconds)
                    .round());
            await _videoController.seekTo(_position);
          },
          path: ImagePaths.fast_forward,
          size: 40,
        ),
      ],
    );
  }

  Widget renderPlaybackSlider() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Slider(
          onChanged: (v) {
            _position = Duration(
                milliseconds: (v * _totalDuration.inMilliseconds).round());
            _videoController.seekTo(_position);
          },
          value: (_position.inMilliseconds > 0 &&
                  _position.inMilliseconds < _totalDuration.inMilliseconds)
              ? _position.inMilliseconds / _totalDuration.inMilliseconds
              : 0.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CText(
                _position.toString().split('.').first,
                style: CTextStyle(fontSize: 12.0, lineHeight: 4.0),
              ),
              CText(
                _totalDuration.toString().split('.').first,
                style: CTextStyle(fontSize: 12.0, lineHeight: 4.0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
