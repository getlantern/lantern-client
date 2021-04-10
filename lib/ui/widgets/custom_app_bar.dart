import 'package:lantern/package_store.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  CustomAppBar({required this.title, this.actions, Key? key}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 1,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        title,
        style: tsHeadline6(context)?.copyWith(fontWeight: FontWeight.bold),
      ),
      actions: actions ?? [],
    );
  }
}
