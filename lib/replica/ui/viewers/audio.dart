import 'package:audioplayers/audioplayers.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';
import 'package:lantern/replica/ui/viewers/layout.dart';
import 'dart:ui';

class ReplicaAudioViewer extends ReplicaViewerLayout {
  ReplicaAudioViewer({
    required ReplicaApi replicaApi,
    required ReplicaSearchItem item,
    required SearchCategory category,
  }) : super(replicaApi: replicaApi, item: item, category: category);

  @override
  State<StatefulWidget> createState() => _ReplicaAudioViewerState();
}

class _ReplicaAudioViewerState extends ReplicaViewerLayoutState
    with TickerProviderStateMixin {
  final mode = PlayerMode.MEDIA_PLAYER;
  final defaultSeekDurationInSeconds = 3;
  late AudioPlayer audioPlayer;
  late AnimationController _controller;
  late Animation<double> _animation;
  Duration? totalDuration;
  Duration? position;
  PlayerState playerState = PlayerState.STOPPED;
  StreamSubscription? durationSubscription;
  StreamSubscription? positionSubscription;
  StreamSubscription? playerCompleteSubscription;
  StreamSubscription? playerErrorSubscription;
  StreamSubscription? playerStateSubscription;
  StreamSubscription? playerControlCommandSubscription;

  bool get isPlaying => playerState == PlayerState.PLAYING;

  @override
  void initState() {
    _controller = AnimationController(
      duration: Duration(
        milliseconds: 40 * (window.physicalSize / window.devicePixelRatio).width.toInt(),
      ),
      lowerBound: -2,
      upperBound: 2,
      vsync: this,
    );
    _animation = _controller
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset();
          _controller.forward();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    audioPlayer = AudioPlayer(mode: mode);
    durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      setState(() => totalDuration = duration);
    });

    positionSubscription = audioPlayer.onAudioPositionChanged.listen(
      (p) => setState(() {
        position = p;
      }),
    );

    playerStateSubscription = audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.STOPPED || event == PlayerState.PAUSED) {
        _controller.stop();
      } else if (event == PlayerState.PLAYING) {
        _controller.forward();
      }
    });

    playerCompleteSubscription = audioPlayer.onPlayerCompletion.listen((event) {
      setState(() => playerState = PlayerState.STOPPED);
      setState(() {
        position = totalDuration;
      });
    });

    playerErrorSubscription = audioPlayer.onPlayerError.listen((msg) {
      logger.w('audioPlayer error : $msg');
      setState(() {
        playerState = PlayerState.STOPPED;
        totalDuration = const Duration();
        position = const Duration();
      });
    });

    playerControlCommandSubscription =
        audioPlayer.notificationService.onPlayerCommand.listen((command) {});

    // play().then((_) {
    //   setState(() {});
    // });
    super.initState();
  }

  Future<int> play() async {
    final playPosition = (position != null &&
            totalDuration != null &&
            position!.inMilliseconds > 0 &&
            position!.inMilliseconds < totalDuration!.inMilliseconds)
        ? position
        : null;
    final result = await audioPlayer.play(
      widget.replicaApi.getDownloadAddr(widget.item.replicaLink),
      position: playPosition,
    );
    if (result == 1) {
      setState(() => playerState = PlayerState.PLAYING);
    }

    return result;
  }

  Future<int> pause() async {
    final result = await audioPlayer.pause();
    if (result == 1) {
      setState(() => playerState = PlayerState.PAUSED);
    }
    return result;
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    durationSubscription?.cancel();
    positionSubscription?.cancel();
    playerCompleteSubscription?.cancel();
    playerErrorSubscription?.cancel();
    playerStateSubscription?.cancel();
    playerControlCommandSubscription?.cancel();
    super.dispose();
  }

  @override
  bool ready() => playerErrorSubscription != null;

  @override
  Widget body(BuildContext context) {
    return Flexible(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: OverflowBox(
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: 208,
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 208,
                child: renderAnimatedMimeIcon(
                  widget.item.fileNameTitle,
                  widget.item.replicaLink,
                  _animation.value,
                ),
              ),
            ),
          ),
          renderWaveform(),
          renderControls()
        ],
      ),
    );
  }

  Widget renderControls() {
    return Container(
      width: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Fast rewind button
          SizedBox(
            width: 32,
            height: 32,
            child: FloatingActionButton(
              heroTag: 'Reverse',
              backgroundColor: HexColor('#ffffff'),
              child: const CAssetImage(
                path: ImagePaths.fast_rewind,
                size: 16,
              ),
              onPressed: () async {
                if (position == null) {
                  return;
                }
                position = Duration(
                  seconds: max(
                    0,
                    position!.inSeconds - defaultSeekDurationInSeconds,
                  ).round(),
                );
                await audioPlayer.seek(position!);
              },
            ),
          ),
          // Play button
          SizedBox(
            width: 56,
            height: 56,
            child: FloatingActionButton(
              heroTag: 'Pause',
              backgroundColor: HexColor('#00BCD4'),
              onPressed: () async {
                isPlaying ? await pause() : await play();
              },
              child: CAssetImage(
                path: isPlaying ? ImagePaths.pause : ImagePaths.play,
                size: 24,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: FloatingActionButton(
              heroTag: 'Forward',
              onPressed: () async {
                if (position == null || totalDuration == null) {
                  return;
                }
                position = Duration(
                  seconds: min(
                    totalDuration!.inSeconds,
                    position!.inSeconds + defaultSeekDurationInSeconds,
                  ).round(),
                );
                await audioPlayer.seek(position!);
              },
              backgroundColor: HexColor('#ffffff'),
              child: const CAssetImage(
                path: ImagePaths.fast_forward,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget renderWaveform() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: white,
        ),
        color: white,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Slider(
              onChanged: (v) {
                final duration = totalDuration;
                if (duration == null) {
                  return;
                }
                final Position = v * duration.inMilliseconds;
                audioPlayer.seek(Duration(milliseconds: Position.round()));
              },
              activeColor: HexColor('#00BCD4'),
              value: (position != null &&
                      totalDuration != null &&
                      position!.inMilliseconds > 0 &&
                      position!.inMilliseconds < totalDuration!.inMilliseconds)
                  ? position!.inMilliseconds / totalDuration!.inMilliseconds
                  : 0.0,
            ),
            // Render the current position duration and total duration at the
            // edges of the container, right below the slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CText(
                    position != null
                        ? position!.toString().split('.').first
                        : '00:00',
                    style: CTextStyle(fontSize: 12.0, lineHeight: 4.0),
                  ),
                  CText(
                    totalDuration != null
                        ? totalDuration!.toString().split('.').first
                        : '00:00',
                    style: CTextStyle(fontSize: 12.0, lineHeight: 4.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
