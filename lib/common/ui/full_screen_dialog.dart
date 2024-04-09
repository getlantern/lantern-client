import 'package:lantern/common/common.dart';

/// Shows the supplied widget as a full screen dialog
@RoutePage<void>(name: 'FullScreenDialogPage')
class FullScreenDialog extends StatelessWidget {
  final Widget widget;
  final Color? bgColor;

  const FullScreenDialog({required this.widget,this.bgColor, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(child: widget),
    );
  }
}
