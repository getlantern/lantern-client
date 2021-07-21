import 'package:lantern/package_store.dart';

/// Shows the supplied widget as a full screen dialog
class FullScreenDialog extends StatelessWidget {
  final Widget widget;
  const FullScreenDialog({required this.widget, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget,
    );
  }
}
