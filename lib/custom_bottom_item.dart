import 'package:lantern/common/common.dart';

class CustomBottomBarItem extends StatelessWidget {
  const CustomBottomBarItem({
    required this.total,
    required this.currentTabIndex,
    required this.tabIndex,
    required this.icon,
    required this.label,
    this.disabled = false,
    this.labelWidget,
    this.addBadge = defaultAddBadge,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final int total;
  final int currentTabIndex;
  final int tabIndex;
  final String label;
  final bool disabled;
  final String icon;
  final Widget? labelWidget;
  final Widget Function(Widget) addBadge;
  final void Function(int) onTap;

  bool get active => currentTabIndex == tabIndex;

  static Widget defaultAddBadge(Widget child) => child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      color: transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: CInkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.only(
                  topStart: Radius.circular(
                    currentTabIndex != 0 ? borderRadius : 0,
                  ),
                  topEnd: Radius.circular(
                    currentTabIndex != total ? borderRadius : 0,
                  ),
                ),
              ),
              onTap: (() {
                if (disabled) {
                  return;
                }
                onTap(tabIndex);
              }),
              child: Container(
                decoration: ShapeDecoration(
                  color: tabIndex == currentTabIndex
                      ? selectedTabColor
                      : unselectedTabColor,
                  shape: CRoundedRectangleBorder(
                    topSide: tabIndex == currentTabIndex
                        ? null
                        : BorderSide(
                            color: borderColor,
                            width: 1,
                          ),
                    endSide: currentTabIndex == tabIndex + 1
                        ? BorderSide(
                            color: borderColor,
                            width: 1,
                          )
                        : null,
                    startSide: currentTabIndex == tabIndex - 1
                        ? BorderSide(
                            color: borderColor,
                            width: 1,
                          )
                        : null,
                    topStartCornerSide: BorderSide(
                      color: currentTabIndex == tabIndex - 1
                          ? borderColor
                          : Colors.white,
                    ),
                    topEndCornerSide: BorderSide(
                      color: currentTabIndex == tabIndex + 1
                          ? borderColor
                          : Colors.white,
                    ),
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(
                        currentTabIndex == tabIndex - 1 ? borderRadius : 0,
                      ),
                      topEnd: Radius.circular(
                        currentTabIndex == tabIndex + 1 ? borderRadius : 0,
                      ),
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: addBadge(
                        CAssetImage(
                          path: icon,
                          color: disabled
                              ? grey4
                              : active
                                  ? selectedTabIconColor
                                  : unselectedTabIconColor,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CText(
                            label,
                            style: tsFloatingLabel.copiedWith(
                              color: disabled
                                  ? grey4
                                  : active
                                      ? black
                                      : grey5,
                            ),
                          ),
                          labelWidget ?? const SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
