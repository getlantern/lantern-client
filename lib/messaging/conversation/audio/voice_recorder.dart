import 'package:lantern/messaging/messaging.dart';

class VoiceRecorder extends StatefulWidget {
  VoiceRecorder({
    Key? key,
    required this.isRecording,
    required this.onRecording,
    required this.onStopRecording,
    required this.onTapUpListener,
  }) : super(key: key);

  final bool isRecording;
  final VoidCallback onRecording;
  final VoidCallback onStopRecording;
  final Function onTapUpListener;

  @override
  _VoiceRecorderState createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late AnimationController _animationController;
  var scaleBoundary;

  @override
  void initState() {
    super.initState();
    scaleBoundary = widget.isRecording ? 2.0 : 1.0;
    _animationController = AnimationController(
      vsync: this,
      lowerBound: 1.0,
      upperBound: 2.0,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.addListener(
      () => setState(() => scaleBoundary = _animationController.value),
    );
    WidgetsBinding.instance!.addObserver(this);
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
      key: const ValueKey('btnRecord'),
      onPanDown: (details) {
        _animationController.forward(from: 1.0);
        _onTapDown(details);
      },
      onPanEnd: (details) {
        _onTapEnd(details);
      },
      child: Transform.scale(
        scale: widget.isRecording ? scaleBoundary : 1.0,
        alignment: Alignment.bottomRight,
        child: Container(
          width: 50,
          height: 50,
          margin: widget.isRecording
              ? const EdgeInsets.only(top: 10)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: widget.isRecording ? red : transparent,
            borderRadius:
                const BorderRadius.only(topLeft: Radius.circular(100)),
          ),
          child: AnimatedSize(
            vsync: this,
            duration: const Duration(milliseconds: 500),
            curve: Curves.linear,
            child: Padding(
              padding: widget.isRecording
                  ? const EdgeInsets.only(top: 10, left: 10)
                  : EdgeInsets.zero,
              child: Icon(
                Icons.mic,
                color: widget.isRecording ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTapEnd(DragEndDetails details) => widget.onStopRecording();

  void _onTapDown(DragDownDetails details) => widget.onRecording();

  @override
  void dispose() {
    _animationController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
