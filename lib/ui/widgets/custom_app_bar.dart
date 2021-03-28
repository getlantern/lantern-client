import 'package:lantern/package_store.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String logoTitle;
  final List<Widget> actions;
  CustomAppBar({this.title, this.logoTitle, this.actions, Key key}) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  Size get preferredSize => new Size.fromHeight(AppBar().preferredSize.height);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 1,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: widget.logoTitle != null
          ? SvgPicture.asset(
              widget.logoTitle,
              height: 16,
              fit: BoxFit.contain,
            )
          : Text(
              widget.title ?? '',
              style: tsTitleAppbar(),
            ),
      actions: widget.actions ?? [],
    );
  }
}
