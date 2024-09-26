import 'package:lantern/core/utils/common.dart';

class PinnedButtonLayout extends StatelessWidget {
  final List<Widget> content;
  final Widget? button;

  PinnedButtonLayout({required this.content, required this.button}) : super();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [...content],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 16, bottom: 32.0),
          child: button,
        ),
      ],
    );
  }
}
