import 'package:lantern/common/common.dart';

class CListItem extends StatelessWidget {
  final BuildContext context;
  final String title;
  final Widget? leading;
  final Widget? trailing;
  void Function()? onTap;

  CListItem(
      {required this.context,
      required this.title,
      this.leading,
      this.trailing,
      this.onTap,
      Key? key})
      : super();

  @override
  Widget build(BuildContext context) => ListTile(
        leading: leading,
        title: CText(title, style: tsSubtitle1Short),
        contentPadding: const EdgeInsetsDirectional.only(
            top: 7, bottom: 5, start: 16, end: 16),
        trailing: trailing,
        onTap: onTap,
      );
}
