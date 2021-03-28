import 'package:lantern/package_store.dart';

class CustomBottomBar extends StatefulWidget {
  final int currentIndex;
  final Function updateCurrentIndexPageView;

  CustomBottomBar(
      {this.currentIndex = 0, this.updateCurrentIndexPageView, Key key})
      : super(key: key);

  @override
  _CustomBottomBarState createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  Widget activeIcon({bool isActive = false}) {
    return Container(
      margin: EdgeInsets.only(left: 4),
      height: activeIconSize,
      width: activeIconSize,
      decoration: BoxDecoration(
        color: isActive ? HexColor(greenDotColor) : HexColor(redDotColor),
        borderRadius: BorderRadius.all(
          Radius.circular(activeIconSize / 2),
        ),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: Colors.green.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 0), // changes position of shadow
          ),
        ]
            : [],
      ),
    );
  }

  Widget renderBottomTabItem({TAB_ENUM tabEnum, int index, bool isActive = false}) {
    String text;
    String icon;

    // Tab(text: 'VPN'.i18n, icon: Icon(Icons.vpn_key)),
    // Tab(text: 'Account'.i18n, icon: Icon(Icons.person)),
    switch (tabEnum) {
      case TAB_ENUM.VPN:
        text = 'VPN'.i18n;
        icon = ImagePaths.key_icon;
        break;
      case TAB_ENUM.ACCOUNT:
        text = 'Account'.i18n;
        icon = ImagePaths.account_icon;
        break;
      default:
        break;
    }
    return Expanded(
      flex: 1,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(
              index != 0 ? borderRadius : 0,
            ),
            topRight: Radius.circular(index != TAB_ENUM.values.length - 1 ? borderRadius : 0),
          ),
        ),
        onTap: () => widget.updateCurrentIndexPageView(index),
        child: Ink(
          decoration: ShapeDecoration(
            color: widget.currentIndex == index ? HexColor(selectedTabColor) : HexColor(unselectedTabColor),
            shape: CustomRoundedRectangleBorder(
              topSide: widget.currentIndex == index
                  ? null
                  : BorderSide(
                color: HexColor(borderColor),
                width: 1,
              ),
              rightSide: widget.currentIndex == index || widget.currentIndex == 2 && index == 0 || widget.currentIndex == 0 && index == 1
                  ? null
                  : BorderSide(
                color: HexColor(borderColor),
                width: 1,
              ),
              leftSide: widget.currentIndex == index || widget.currentIndex == 0 && index == 2 || widget.currentIndex == 2 && index == 1
                  ? null
                  : BorderSide(
                color: HexColor(borderColor),
                width: 1,
              ),
              topLeftCornerSide: BorderSide(
                color: (widget.currentIndex == 0 && index == 1) || (widget.currentIndex == 1 && index == 2) ? HexColor(borderColor) : Colors.white,
              ),
              topRightCornerSide: BorderSide(
                color: (widget.currentIndex == 1 && index == 0) || (widget.currentIndex == 2 && index == 1) ? HexColor(borderColor) : Colors.white,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  (widget.currentIndex == 0 && index == 1) || (widget.currentIndex == 1 && index == 2) ? borderRadius : 0,
                ),
                topRight: Radius.circular(
                  (widget.currentIndex == 1 && index == 0) || (widget.currentIndex == 2 && index == 1) ? borderRadius : 0,
                ),
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomAssetImage(
                path: icon,
                size: 24,
                color: HexColor(widget.currentIndex == index ? selectedTabLabelColor : unselectedTabLabelColor),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text ?? "",
                    style: GoogleFonts.roboto().copyWith(
                      fontSize: 12,
                      color: HexColor(widget.currentIndex == index ? selectedTabLabelColor : unselectedTabLabelColor),
                    ),
                  ),
                  tabEnum == TAB_ENUM.VPN ? activeIcon(isActive: isActive) : Container(),
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
    return vpnModel.vpnStatus((BuildContext context, String vpnStatus, Widget child) {
      return Container(
        height: 68,
        child: Row(
          children: TAB_ENUM.values
              .asMap()
              .map(
                (index, tabEnum) => MapEntry(
              index,
              renderBottomTabItem(
                index: index,
                tabEnum: tabEnum,
                isActive: vpnStatus == "connected" || vpnStatus == "disconnecting",
              ),
            ),
          )
              .values
              .toList(),
        ),
      );
    });
  }
}