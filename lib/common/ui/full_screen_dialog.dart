import 'package:lantern/common/common.dart';

/// Shows the supplied widget as a full screen dialog
@RoutePage<void>(name: 'FullScreenDialogPage')
class FullScreenDialog extends StatelessWidget {
  final Widget widget;

  const FullScreenDialog({required this.widget, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: widget),
    );
  }
}
