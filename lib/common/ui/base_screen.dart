import 'package:lantern/common/common.dart';

class BaseScreen extends StatelessWidget {
  final dynamic title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? actionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? centerTitle;

  BaseScreen(
      {this.title,
      this.actions,
      required this.body,
      this.actionButton,
      this.floatingActionButtonLocation,
      this.centerTitle = true,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: title.runtimeType == String
            ? Text(
                title,
                style: tsTitleAppbar,
              )
            : title,
        elevation: 1,
        backgroundColor: Colors.white,
        centerTitle: centerTitle,
        actions: actions,
      ),
      body: body,
      floatingActionButton: actionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
