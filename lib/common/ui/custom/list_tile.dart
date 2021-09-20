import 'package:lantern/common/common.dart';

class CListItem extends StatelessWidget {
  final BuildContext context;
  final String title;
  final IconData? leadingIcon;
  final String? leadingPath;
  final IconData? trailingIcon;
  final String? trailingPath;
  void Function()? onTap;

  CListItem(
      {required this.context,
      required this.title,
      this.leadingIcon,
      this.trailingIcon,
      this.leadingPath,
      this.trailingPath,
      this.onTap,
      Key? key})
      : super();

  @override
  Widget build(BuildContext context) => ListTile(
        leading: leadingPath!.isNotEmpty
            ? CAssetImage(
                path: leadingPath!,
                size: 20,
              )
            : Icon(leadingIcon!, size: 20),
        title: CText(title, style: tsSubtitle1Short),
        contentPadding: const EdgeInsetsDirectional.only(
            top: 7, bottom: 5, start: 16, end: 16),
        trailing: trailingPath!.isNotEmpty
            ? CAssetImage(
                path: trailingPath!,
                size: 20,
              )
            : Icon(trailingIcon!, size: 20),
        onTap: onTap,
      );
}
