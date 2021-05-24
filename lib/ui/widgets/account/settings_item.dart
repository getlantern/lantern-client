import 'package:lantern/package_store.dart';

import '../continue_arrow.dart';

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
      SizedBox(
        height: 72,
        child: InkWell(
          onTap: onTap ?? () {},
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 16),
                    child: CustomAssetImage(
                      path: icon!,
                      size: 24,
                      color: iconColor,
                    ),
                  ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    child: Row(
                      children: [
                        if (title != null)
                          Flexible(
                            child: Tooltip(
                              message: title!,
                              child: Text(
                                title!,
                                overflow: TextOverflow.ellipsis,
                                style: tsTitleItem(),
                              ),
                            ),
                          ),
                        if (openInfoDialog != null)
                          Container(
                            transform:
                                Matrix4.translationValues(-8.0, 0.0, 0.0),
                            child: InkWell(
                              onTap: () {
                                openInfoDialog!(context);
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(16),
                                child: CustomAssetImage(
                                  path: ImagePaths.info_icon,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (child != null) child!,
                      if (showArrow) const ContinueArrow(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      CustomDivider(height: 1),
    ]);
  }
}
