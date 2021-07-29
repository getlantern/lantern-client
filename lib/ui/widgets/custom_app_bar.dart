import 'package:lantern/package_store.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? logoTitle;
  final List<Widget>? actions;
  final bool? centerTitle;

  CustomAppBar(
      {this.title = '',
      this.logoTitle,
      this.actions,
      this.centerTitle,
      Key? key})
      : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        centerTitle: centerTitle == null,
        title: logoTitle != null
            ? SvgPicture.asset(
                logoTitle!,
                height: 16,
                fit: BoxFit.contain,
              )
            : Text(
                title,
                style: tsTitleAppbar,
              ),
        actions: actions);
  }
}
