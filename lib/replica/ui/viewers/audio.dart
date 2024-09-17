import 'package:audioplayers/audioplayers.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';
import 'package:lantern/replica/ui/viewers/layout.dart';

@RoutePage(name: 'ReplicaAudioViewer')
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
  final defaultSeekDurationInSeconds = 3;
  late AudioPlayer audioPlayer;
  late AnimationController _controller;
  late Animation<double> _animation;
  Duration? totalDuration;
  Duration? position;
  PlayerState playerState = PlayerState.stopped;
  StreamSubscription? durationSubscription;
  StreamSubscription? positionSubscription;
  StreamSubscription? playerCompleteSubscription;
  StreamSubscription? playerStateSubscription;

  bool get isPlaying => playerState == PlayerState.playing;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 8000,
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
    audioPlayer = AudioPlayer();
    durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      setState(() => totalDuration = duration);
    });

    positionSubscription = audioPlayer.onPositionChanged.listen(
      (p) => setState(() {
        position = p;
      }),
    );

    playerStateSubscription = audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.stopped || event == PlayerState.paused) {
        _controller.stop();
      } else if (event == PlayerState.playing) {
        _controller.forward();
      }
    });

    playerCompleteSubscription = audioPlayer.onPlayerComplete.listen((event) {
      setState(() => playerState = PlayerState.stopped);
      setState(() {
        position = totalDuration;
      });
    });
  }

  Future<void> play() async {
    final playPosition = (position != null &&
            totalDuration != null &&
            position!.inMilliseconds > 0 &&
            position!.inMilliseconds < totalDuration!.inMilliseconds)
        ? position
        : null;
    await audioPlayer.play(
      UrlSource(widget.replicaApi.getDownloadAddr(widget.item.replicaLink)),
      position: playPosition,
    );
    setState(() => playerState = PlayerState.playing);
  }

  Future<void> pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    durationSubscription?.cancel();
    positionSubscription?.cancel();
    playerCompleteSubscription?.cancel();
    playerStateSubscription?.cancel();
    super.dispose();
  }

  @override
  bool ready() => playerStateSubscription != null;

  @override
  Widget body(BuildContext context) {
    return Flexible(
      flex: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            child: renderAnimatedMimeIcon(
              widget.item.fileNameTitle,
              widget.item.replicaLink,
              _animation.value,
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
