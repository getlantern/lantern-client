import 'package:lantern/package_store.dart';

import 'custom_rounded_rectangle_border.dart';

class TabItem {
  final int index;
  final String title;
  final String icon;

  TabItem({required this.index, required this.title, required this.icon});
}

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final bool showDeveloperSettings;
  final Function updateCurrentIndexPageView;
  final List<TabItem> tabs = [
    TabItem(index: 0, title: 'VPN', icon: ImagePaths.key_icon),
    TabItem(index: 1, title: 'Account', icon: ImagePaths.account_icon),
  ];

  CustomBottomBar(
      {this.currentIndex = 0,
      this.showDeveloperSettings = false,
      required this.updateCurrentIndexPageView,
      Key? key})
      : super(key: key) {
    if (showDeveloperSettings) {
      tabs.add(TabItem(
          index: 2, title: 'Developer'.i18n, icon: ImagePaths.devices_icon));
    }
  }

  Widget activeIcon({bool isActive = false}) {
    return Container(
      margin: const EdgeInsetsDirectional.only(start: 4),
      height: activeIconSize,
      width: activeIconSize,
      decoration: BoxDecoration(
        color: isActive ? indicatorGreen : indicatorRed,
        borderRadius: const BorderRadius.all(
          Radius.circular(activeIconSize / 2),
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 0), // changes position of shadow
                ),
              ]
            : [],
      ),
    );
  }

  Widget renderBottomTabItem(
      {required TabItem tab,
      bool isActive = false,
      required BuildContext context}) {
    var sessionModel = context.watch<SessionModel>();
    var selected = currentIndex == tab.index;
    var tabIsFirst = tab.index == 0;
    var tabIsLast = tab.index == tabs.length - 1;
    var selectedIsPrior = currentIndex == tab.index - 1;
    var selectedIsNext = currentIndex == tab.index + 1;

    return Expanded(
      flex: 1,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(
              !tabIsFirst ? borderRadius : 0,
            ),
            topEnd: Radius.circular(!tabIsLast ? borderRadius : 0),
          ),
        ),
        onTap: () => updateCurrentIndexPageView(tab.index),
        child: Ink(
          decoration: ShapeDecoration(
            color: selected ? selectedTabColor : unselectedTabColor,
            shape: CustomRoundedRectangleBorder(
              topSide: selected
                  ? null
                  : BorderSide(
                      color: borderColor,
                      width: 1,
                    ),
              endSide: selectedIsNext
                  ? BorderSide(
                      color: borderColor,
                      width: 1,
                    )
                  : null,
              startSide: selectedIsPrior
                  ? BorderSide(
                      color: borderColor,
                      width: 1,
                    )
                  : null,
              topStartCornerSide: BorderSide(
                color: selectedIsPrior ? borderColor : Colors.white,
              ),
              topEndCornerSide: BorderSide(
                color: selectedIsNext ? borderColor : Colors.white,
              ),
              borderRadius: BorderRadiusDirectional.only(
                topStart: Radius.circular(
                  selectedIsPrior ? borderRadius : 0,
                ),
                topEnd: Radius.circular(
                  selectedIsNext ? borderRadius : 0,
                ),
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomAssetImage(
                path: tab.icon,
                size: 24,
                color:
                    selected ? selectedTabLabelColor : unselectedTabLabelColor,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tab.title.i18n,
                    style: GoogleFonts.roboto().copyWith(
                      fontSize: 12,
                      color: selected
                          ? selectedTabLabelColor
                          : unselectedTabLabelColor,
                    ),
                  ),
                  tab.title == 'VPN'
                      ? activeIcon(isActive: isActive)
                      : Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var vpnModel = context.watch<VpnModel>();
    return Container(
      height: 68,
      child: vpnModel
          .vpnStatus((BuildContext context, String? vpnStatus, Widget? child) {
        return Row(
          children: tabs
              .map(
                (tab) => renderBottomTabItem(
                    tab: tab,
                    isActive: (vpnStatus == 'connected' ||
                        vpnStatus == 'disconnecting'),
                    context: context),
              )
              .toList(),
        );
      }),
    );
  }
}
