import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lantern/config/colors.dart';
import 'package:lantern/config/image_paths.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/custom_bottom_item.dart';
import 'package:lantern/ui/widgets/custom_badge.dart';
import 'package:sizer/sizer.dart';

class CustomBottomBar extends StatelessWidget {
  final int index;
  final Function(int)? onTap;
  final bool isDevelop;

  const CustomBottomBar(
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
      elevation: 0.0,
      unselectedFontSize: 0,
      selectedFontSize: 0,
      showSelectedLabels: false,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: CustomBottomItem(
            currentIndex: index,
            position: 0,
            total: isDevelop ? 4 : 3,
            label: Text('Messages'.i18n, style: TextStyle(fontSize: 9.sp)),
            icon: SvgPicture.asset(
              ImagePaths.messages_icon,
              color:
                  index == 0 ? selectedTabLabelColor : unselectedTabLabelColor,
              fit: BoxFit.contain,
            ),
            onTap: () => onTap!(0),
          ),
          label: '',
          tooltip: 'Messages'.i18n,
        ),
        BottomNavigationBarItem(
          icon: CustomBottomItem(
            currentIndex: index,
            position: 1,
            total: isDevelop ? 4 : 3,
            label: Text('VPN', style: TextStyle(fontSize: 9.sp)),
            icon: SvgPicture.asset(
              ImagePaths.key_icon,
              color:
                  index == 1 ? selectedTabLabelColor : unselectedTabLabelColor,
              fit: BoxFit.contain,
            ),
            onTap: () => onTap!(1),
            iconWidget: vpnModel.vpnStatus(
              (context, value, child) => CircleAvatar(
                maxRadius: activeIconSize - 4,
                backgroundColor: (value.toLowerCase() ==
                            'Disconnecting'.i18n.toLowerCase() ||
                        value == 'Connected'.i18n.toLowerCase())
                    ? indicatorGreen
                    : indicatorRed,
              ),
            ),
          ),
          label: '',
          tooltip: 'VPN',
        ),
        BottomNavigationBarItem(
          icon: CustomBottomItem(
            currentIndex: index,
            position: 2,
            total: isDevelop ? 4 : 3,
            label: Text('Account'.i18n, style: TextStyle(fontSize: 9.sp)),
            onTap: () => onTap!(2),
            icon: sessionModel.shouldShowYinbiBadge(
              (context, value, child) => CustomBadge(
                count: 1,
                fontSize: 8.0,
                showBadge: value,
                child: SvgPicture.asset(
                  ImagePaths.account_icon,
                  color: index == 2
                      ? selectedTabLabelColor
                      : unselectedTabLabelColor,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          label: '',
          tooltip: 'Account'.i18n,
        ),
        BottomNavigationBarItem(
          icon: CustomBottomItem(
            currentIndex: index,
            position: 3,
            total: isDevelop ? 4 : 3,
            label: Text('Developer'.i18n, style: TextStyle(fontSize: 9.sp)),
            icon: SvgPicture.asset(
              ImagePaths.devices_icon,
              color:
                  index == 3 ? selectedTabLabelColor : unselectedTabLabelColor,
              fit: BoxFit.contain,
            ),
            onTap: () => onTap!(3),
          ),
          label: '',
          tooltip: 'Developer'.i18n,
        ),
      ],
    );
  }
}
