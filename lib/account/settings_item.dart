import 'package:lantern/account/account.dart';
import 'package:lantern/common/common.dart';

import '../common/ui/continue_arrow.dart';

class SettingsItem extends StatelessWidget {
  late final String? icon;
  late final Color? iconColor;
  late final String? title;
  final bool showArrow;
  final Widget? child;
  final void Function(BuildContext context)? openInfoDialog;
  final void Function()? onTap;

  SettingsItem(
      {this.icon,
      this.iconColor,
      this.title,
      this.showArrow = false,
      this.openInfoDialog,
      this.onTap,
      this.child});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CListTile(
        leading: icon != null
            ? CAssetImage(
                path: icon!,
                color: iconColor,
              )
            : const SizedBox(),
        content: Row(
          children: [
            if (title != null)
              Flexible(
                child: Tooltip(
                  message: title!,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 1),
                    child: CText(
                      title!,
                      maxLines: 1,
                      style: tsSubtitle1Short,
                    ),
                  ),
                ),
              ),
            if (openInfoDialog != null)
              InkWell(
                onTap: () {
                  openInfoDialog!(context);
                },
                child: const Padding(
                  padding: EdgeInsetsDirectional.only(start: 16, end: 16),
                  child: CAssetImage(
                    path: ImagePaths.info,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            child ?? const SizedBox(),
            if (showArrow) const ContinueArrow(),
          ],
        ),
        onTap: onTap,
      ),
      CVerticalDivider(height: 1),
    ]);
  }
}
