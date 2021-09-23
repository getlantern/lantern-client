import 'package:lantern/common/common.dart';

class BaseScreen extends StatelessWidget {
  final dynamic title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? actionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? centerTitle;
  final bool resizeToAvoidBottomInset;
  final bool padHorizontal;
  final bool padVertical;

  BaseScreen(
      {this.title,
      this.actions,
      required this.body,
      this.actionButton,
      this.floatingActionButtonLocation,
      this.centerTitle = true,
      this.resizeToAvoidBottomInset = true,
      this.padHorizontal = true,
      this.padVertical = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: AppBar(
        title: title is String
            ? CText(
                title,
                style: tsHeading3,
              )
            : title,
        elevation: 1,
        backgroundColor: Colors.white,
        centerTitle: centerTitle,
        titleSpacing: 0,
        actions: actions,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: padHorizontal ? 16 : 0, vertical: padVertical ? 16 : 0),
        child: body,
      ),
      floatingActionButton: actionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
