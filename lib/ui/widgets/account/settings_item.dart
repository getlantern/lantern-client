import 'package:lantern/package_store.dart';

class SettingsItem extends StatelessWidget {
  late final String icon;
  late final String title;
  final bool showArrow;
  late final double inkVerticalPadding;
  final Widget? child;
  final void Function(BuildContext context)? openInfoDialog;
  final void Function()? onTap;

  SettingsItem(
      {required this.icon,
      required this.title,
      this.showArrow = false,
      this.inkVerticalPadding = 16,
      this.openInfoDialog,
      this.onTap,
      this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 8,
      ),
      child: InkWell(
        onTap: onTap ?? () {},
        child: Ink(
          padding: EdgeInsets.symmetric(
            vertical: inkVerticalPadding,
            horizontal: 24,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CustomAssetImage(
                  path: icon,
                  size: 24,
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Container(
                  child: Row(
                    children: [
                      Flexible(
                        child: Tooltip(
                          message: title,
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: tsTitleItem(),
                          ),
                        ),
                      ),
                      if (openInfoDialog != null)
                        Container(
                          transform: Matrix4.translationValues(-8.0, 0.0, 0.0),
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
                      if (showArrow)
                        const CustomAssetImage(
                          path: ImagePaths.keyboard_arrow_right_icon,
                          size: 24,
                        ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
