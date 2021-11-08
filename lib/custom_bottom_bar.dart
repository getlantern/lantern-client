import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lantern/common/ui/colors.dart';
import 'package:lantern/common/ui/image_paths.dart';
import 'package:lantern/custom_bottom_item.dart';
import 'package:lantern/common/common.dart';

import 'messaging/messaging_model.dart';

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
    var messagingModel = context.watch<MessagingModel>();

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
          icon: CustomBottomBarItem(
            currentIndex: index,
            position: 0,
            total: isDevelop ? 4 : 3,
            label: CText('secure_chat'.i18n, style: tsFloatingLabel),
            icon: SvgPicture.asset(
              ImagePaths.messages,
              color:
                  index == 0 ? selectedTabLabelColor : unselectedTabLabelColor,
              fit: BoxFit.contain,
            ),
            onTap: () => onTap!(0),
          ),
          label: '',
          tooltip: 'chats'.i18n,
        ),
        BottomNavigationBarItem(
          icon: CustomBottomBarItem(
            currentIndex: index,
            position: 1,
            total: isDevelop ? 4 : 3,
            label: CText('VPN'.i18n, style: tsFloatingLabel),
            icon: SvgPicture.asset(
              ImagePaths.key,
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
                    ? indicatorGreen
                    : indicatorRed,
              ),
            ),
          ),
          label: '',
          tooltip: 'VPN'.i18n,
        ),
        BottomNavigationBarItem(
          icon: CustomBottomBarItem(
            currentIndex: index,
            position: 2,
            total: isDevelop ? 4 : 3,
            label: CText('Account'.i18n, style: tsFloatingLabel),
            onTap: () => onTap!(2),
            icon: messagingModel.getCopiedRecoveryStatus(
                (context, hasCopiedRecoveryKey, child) => CBadge(
                      count: 1,
                      showBadge: !hasCopiedRecoveryKey,
                      child: SvgPicture.asset(
                        ImagePaths.account,
                        color: index == 2
                            ? selectedTabLabelColor
                            : unselectedTabLabelColor,
                        fit: BoxFit.contain,
                      ),
                    )),
          ),
          label: '',
          tooltip: 'Account'.i18n,
        ),
        if (isDevelop)
          BottomNavigationBarItem(
            icon: CustomBottomBarItem(
              currentIndex: index,
              position: 3,
              total: isDevelop ? 4 : 3,
              label: CText('Developer'.i18n, style: tsFloatingLabel),
              icon: SvgPicture.asset(
                ImagePaths.devices,
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
