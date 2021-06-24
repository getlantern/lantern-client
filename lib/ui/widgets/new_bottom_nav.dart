import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lantern/config/colors.dart';
import 'package:lantern/config/image_paths.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/custom_badge.dart';

class NewBottomNav extends StatelessWidget {
  final int index;
  final Function(int)? onTap;
  final bool isDevelop;

  const NewBottomNav(
      {required this.index,
      required this.isDevelop,
      required this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();
    var vpnModel = context.watch<VpnModel>();

    return BottomNavigationBar(
      currentIndex: index,
      iconSize: 24,
      backgroundColor: unselectedTabColor,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(color: selectedTabLabelColor, fontSize: 15),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      unselectedLabelStyle:
          TextStyle(color: unselectedTabLabelColor, fontSize: 15),
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          backgroundColor: index == 0 ? selectedTabColor : unselectedTabColor,
          icon: SvgPicture.asset(
            ImagePaths.messages_icon,
            color: unselectedTabLabelColor,
            fit: BoxFit.contain,
          ),
          activeIcon: SvgPicture.asset(
            ImagePaths.messages_icon,
            color: selectedTabLabelColor,
            fit: BoxFit.contain,
          ),
          label: 'Messaging',
          tooltip: 'Messaging',
        ),
        BottomNavigationBarItem(
          backgroundColor: index == 1 ? selectedTabColor : unselectedTabColor,
          icon: vpnModel.vpnStatus(
            (context, value, child) => Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  ImagePaths.key_icon,
                  color: unselectedTabLabelColor,
                  fit: BoxFit.contain,
                ),
                Positioned(
                  right: 1,
                  top: 1,
                  child: CircleAvatar(
                    maxRadius: activeIconSize - 4,
                    backgroundColor:
                        (value == 'disconnecting' || value == 'connected')
                            ? indicatorGreen
                            : indicatorRed,
                  ),
                ),
              ],
            ),
          ),
          activeIcon: vpnModel.vpnStatus(
            (context, value, child) => Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  ImagePaths.key_icon,
                  color: selectedTabLabelColor,
                  fit: BoxFit.contain,
                ),
                Positioned(
                  right: 1,
                  top: 1,
                  child: CircleAvatar(
                    maxRadius: activeIconSize - 4,
                    backgroundColor:
                        (value == 'disconnecting' || value == 'connected')
                            ? indicatorGreen
                            : indicatorRed,
                  ),
                ),
              ],
            ),
          ),
          label: 'VPN',
          tooltip: 'VPN',
        ),
        BottomNavigationBarItem(
          backgroundColor: index == 2 ? selectedTabColor : unselectedTabColor,
          icon: sessionModel.shouldShowYinbiBadge(
            (context, value, child) => CustomBadge(
              count: 1,
              fontSize: 8.0,
              showBadge: value,
              child: SvgPicture.asset(
                ImagePaths.account_icon,
                color: unselectedTabLabelColor,
                fit: BoxFit.contain,
              ),
            ),
          ),
          activeIcon: sessionModel.shouldShowYinbiBadge(
            (context, value, child) => CustomBadge(
              count: 1,
              fontSize: 8.0,
              showBadge: value,
              child: SvgPicture.asset(
                ImagePaths.account_icon,
                color: selectedTabLabelColor,
                fit: BoxFit.contain,
              ),
            ),
          ),
          label: 'Account',
          tooltip: 'Account',
        ),
        if (isDevelop)
          BottomNavigationBarItem(
            backgroundColor: index == 3 ? selectedTabColor : unselectedTabColor,
            icon: SvgPicture.asset(
              ImagePaths.devices_icon,
              color: unselectedTabLabelColor,
              fit: BoxFit.contain,
            ),
            activeIcon: SvgPicture.asset(
              ImagePaths.devices_icon,
              color: selectedTabLabelColor,
              fit: BoxFit.contain,
            ),
            label: 'Developer',
            tooltip: 'Developer',
          ),
      ],
    );
  }
}
