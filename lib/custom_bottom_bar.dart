import 'package:flutter/material.dart';
import 'package:lantern/common/ui/colors.dart';
import 'package:lantern/common/ui/image_paths.dart';
import 'package:lantern/custom_bottom_item.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/logic/common.dart';

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
            icon: CAssetImage(
              path: ImagePaths.messages,
              color:
                  index == 0 ? selectedTabLabelColor : unselectedTabLabelColor,
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
            label: CText('VPN'.i18n, style: tsFloatingLabel),
            icon: CAssetImage(
              path: ImagePaths.key,
              color:
                  index == 1 ? selectedTabLabelColor : unselectedTabLabelColor,
            ),
            onTap: () => onTap!(1),
            iconWidget: vpnModel.vpnStatus(
              (context, value, child) => CircleAvatar(
                maxRadius: activeIconSize - 4,
                backgroundColor: (value.toLowerCase() ==
                            'Disconnecting'.i18n.toLowerCase() ||
                        value == 'connected'.i18n.toLowerCase())
                    ? indicatorGreen
                    : indicatorRed,
              ),
            ),
          ),
          label: '',
          tooltip: 'VPN'.i18n,
        ),
        BottomNavigationBarItem(
          icon: CustomBottomItem(
            currentIndex: index,
            position: 2,
            total: isDevelop ? 4 : 3,
            label: CText('Account'.i18n, style: tsFloatingLabel),
            onTap: () => onTap!(2),
            icon: CAssetImage(
              path: ImagePaths.account,
              color:
                  index == 2 ? selectedTabLabelColor : unselectedTabLabelColor,
            ),
          ),
          label: '',
          tooltip: 'Account'.i18n,
        ),
        if (ReplicaCommon.isReplicaRunning())
          BottomNavigationBarItem(
            icon: CustomBottomItem(
              currentIndex: index,
              position: 3,
              total: isDevelop ? 4 : 3,
              label: CText('Discover'.i18n, style: tsFloatingLabel),
              icon: CAssetImage(
                path: ImagePaths.discover,
                color: index == 3
                    ? selectedTabLabelColor
                    : unselectedTabLabelColor,
              ),
              onTap: () => onTap!(3),
            ),
            label: '',
            tooltip: 'Discover'.i18n,
          ),
        if (isDevelop)
          BottomNavigationBarItem(
            icon: CustomBottomItem(
              currentIndex: index,
              position: 4,
              total: isDevelop ? 4 : 3,
              label: CText('Developer'.i18n, style: tsFloatingLabel),
              icon: CAssetImage(
                path: ImagePaths.devices,
                color: index == 4
                    ? selectedTabLabelColor
                    : unselectedTabLabelColor,
              ),
              onTap: () => onTap!(4),
            ),
            label: '',
            tooltip: 'Developer'.i18n,
          ),
      ],
    );
  }
}
