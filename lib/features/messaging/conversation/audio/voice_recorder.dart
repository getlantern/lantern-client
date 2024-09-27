import 'package:lantern/features/messaging/messaging.dart';

class VoiceRecorder extends StatefulWidget {
  VoiceRecorder({
    Key? key,
    required this.isRecording,
    required this.onRecording,
    required this.onStopRecording,
    required this.onTapUpListener,
  }) : super(key: key);

  final bool isRecording;
  final Future<void> Function() onRecording;
  final Future<void> Function() onStopRecording;
  final Future<void> Function() onTapUpListener;

  @override
  _VoiceRecorderState createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  static const startingScale = 0.0;
  static const endingScale = 80.0 / 57.0;
  var scale = 1.0;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    animationController = AnimationController(
      vsync: this,
      lowerBound: startingScale,
      upperBound: endingScale,
      duration: const Duration(milliseconds: 300),
    );
    animationController.addListener(
      () => setState(() => scale = animationController.value),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        if (widget.isRecording) widget.onStopRecording();
        break;
      case AppLifecycleState.resumed:
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) async {
        unawaited(HapticFeedback.lightImpact());
        unawaited(animationController.forward(from: startingScale));
        await widget.onRecording();
      },
      onPanEnd: (details) async {
        await widget.onStopRecording();
        setState(() {
          scale = 1;
        });
      },
      onTapUp: (details) async {
        animationController.stop(canceled: true);
        unawaited(HapticFeedback.lightImpact());
        await widget.onTapUpListener();
        setState(() {
          scale = 1;
        });
      },
      child: Transform.scale(
        alignment:
            isLTR(context) ? Alignment.bottomRight : Alignment.bottomLeft,
        scale: scale,
        child: Container(
          alignment:
              isLTR(context) ? Alignment.bottomRight : Alignment.bottomLeft,
          height: messageBarHeight,
          width: messageBarHeight,
          decoration: BoxDecoration(
            color: widget.isRecording ? indicatorRed : transparent,
            borderRadius: isLTR(context)
                ? const BorderRadius.only(topLeft: Radius.circular(1000))
                : const BorderRadius.only(topRight: Radius.circular(1000)),
          ),
          child: Padding(
            padding: widget.isRecording
                ? const EdgeInsetsDirectional.only(bottom: 12, end: 8)
                : const EdgeInsetsDirectional.only(bottom: 15, end: 16),
            child: CAssetImage(
              path: ImagePaths.mic,
              color: widget.isRecording ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
