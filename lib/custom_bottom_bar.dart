import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lantern/common/ui/colors.dart';
import 'package:lantern/common/ui/image_paths.dart';
import 'package:lantern/custom_bottom_item.dart';
import 'package:lantern/common/common.dart';

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
            label: CText('messages'.i18n, style: tsFloatingLabel),
            icon: SvgPicture.asset(
              ImagePaths.messages_icon,
              color:
                  index == 0 ? selectedTabLabelColor : unselectedTabLabelColor,
              fit: BoxFit.contain,
            ),
            onTap: () => onTap!(0),
          ),
          label: '',
          tooltip: 'messages'.i18n,
        ),
        BottomNavigationBarItem(
          icon: CustomBottomItem(
            currentIndex: index,
            position: 1,
            total: isDevelop ? 4 : 3,
            label: CText('VPN', style: tsFloatingLabel),
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
                        value == 'connected'.i18n.toLowerCase())
                    ? green
                    : red,
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
            label: CText('Account'.i18n, style: tsFloatingLabel),
            onTap: () => onTap!(2),
            icon: SvgPicture.asset(
              ImagePaths.account_icon,
              color:
                  index == 2 ? selectedTabLabelColor : unselectedTabLabelColor,
              fit: BoxFit.contain,
            ),
          ),
          label: '',
          tooltip: 'Account'.i18n,
        ),
        if (isDevelop)
          BottomNavigationBarItem(
            icon: CustomBottomItem(
              currentIndex: index,
              position: 3,
              total: isDevelop ? 4 : 3,
              label: CText('Developer'.i18n, style: tsFloatingLabel),
              icon: SvgPicture.asset(
                ImagePaths.devices_icon,
                color: index == 3
                    ? selectedTabLabelColor
                    : unselectedTabLabelColor,
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
