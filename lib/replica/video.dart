import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:lantern/replica/common.dart';
import 'package:lantern/common/common.dart';

/// ReplicaVideoPlayerScreen takes a 'replicaLink' of a video and attempts to
/// stream it. If it can't stream the link, it'll show an error screen.
///
/// Example:
///
///   ReplicaVideoPlayerScreen(
///     replicaLink:
///       'magnet%3A%3Fxt%3Durn%3Abtih%3A638f6f674c06a05f4cb4e45871beba10ad57818c%26so%3D0'))
///
class ReplicaVideoPlayerScreen extends StatefulWidget {
  ReplicaVideoPlayerScreen({Key? key, required this.replicaLink})
      : super(key: key);
  late _VideoPlayerScreenState state;
  final String replicaLink;

  @override
  _VideoPlayerScreenState createState() {
    state = _VideoPlayerScreenState();
    return state;
  }
}

class _VideoPlayerScreenState extends State<ReplicaVideoPlayerScreen> {
  _VideoPlayerScreenState();
  late VideoPlayerController controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    // XXX <10-11-21, soltzen> Failures of this call are handled after the
    // future returned in the 'build()' function
    controller = VideoPlayerController.network(
      'http://localhost:' +
          replicaPort.toString() +
          '/replica/view?link=' +
          widget.replicaLink,
    );
    _initializeVideoPlayerFuture = controller.initialize();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String? fetchDisplayNameFromReplicaLink(String replicaLink) {
    if (replicaLink.isEmpty) {
      return null;
    }
    final dn = Uri.parse(Uri.decodeFull(replicaLink))
        .queryParameters['dn']; // dn == displayName
    if (dn is String) {
      return dn;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fetchDisplayNameFromReplicaLink(widget.replicaLink) ?? ''),
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // TODO <10-11-21, soltzen> Make this prettier
            if (controller.value.hasError) {
              print(
                  'Received a playback error: ${controller.value.errorDescription}');
              return Center(
                  child: CText(
                // TODO <10-11-21, soltzen> Localize this
                'replica_video_error'.i18n,
                style: tsBody3,
              ));
            }
            return AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (controller.value.isPlaying) {
              controller.pause();
            } else {
              controller.play();
            }
          });
        },
        child: Icon(
          controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
