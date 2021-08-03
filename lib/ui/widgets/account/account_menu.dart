import 'package:lantern/package_store.dart';
import 'package:lantern/ui/routes.dart';
import 'package:lantern/ui/widgets/custom_badge.dart';

import 'settings_item.dart';

class AccountMenu extends StatelessWidget {
  AccountMenu({Key? key}) : super(key: key);

  void upgradeToLanternPro() {
    LanternNavigator.startScreen(
        LanternNavigator.SCREEN_UPGRADE_TO_LANTERN_PRO);
  }

  void authorizeDeviceForPro(BuildContext context) {
    Navigator.pushNamed(context, routeAuthorizeDeviceForPro);
  }

  void inviteFriends() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_INVITE_FRIEND);
  }

  void openDesktopVersion() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_DESKTOP_VERSION);
  }

  void openSettings(BuildContext context) {
    Navigator.pushNamed(context, routeSettings);
  }

  List<Widget> freeItems(BuildContext context, SessionModel sessionModel) {
    return [
      SettingsItem(
        icon: ImagePaths.crown_icon_monochrome,
        title: 'upgrade_to_lantern_pro'.i18n,
        onTap: upgradeToLanternPro,
      ),
      SettingsItem(
        icon: ImagePaths.devices_icon,
        title: 'authorize_device_for_pro'.i18n,
        onTap: () {
          authorizeDeviceForPro(context);
        },
      ),
      SettingsItem(
        icon: ImagePaths.star_icon,
        title: 'invite_friends'.i18n,
        onTap: inviteFriends,
      ),
      SettingsItem(
        icon: ImagePaths.desktop_icon,
        title: 'desktop_version'.i18n,
        onTap: openDesktopVersion,
      ),
      SettingsItem(
        icon: ImagePaths.settings_icon,
        title: 'settings'.i18n,
        onTap: () {
          openSettings(context);
        },
      ),
    ];
  }

  List<Widget> proItems(BuildContext context) {
    return [
      SettingsItem(
        icon: ImagePaths.account_icon,
        iconColor: Colors.black,
        title: 'pro_account_management'.i18n,
        onTap: () {
          Navigator.pushNamed(context, routeProAccount);
        },
      ),
      SettingsItem(
          icon: ImagePaths.devices_icon,
          title: 'add_device'.i18n,
          onTap: () {
            Navigator.pushNamed(context, routeApproveDevice);
          }),
      SettingsItem(
        icon: ImagePaths.star_icon,
        title: 'invite_friends'.i18n,
        onTap: inviteFriends,
      ),
      SettingsItem(
        icon: ImagePaths.desktop_icon,
        title: 'desktop_version'.i18n,
        onTap: openDesktopVersion,
      ),
      SettingsItem(
        icon: ImagePaths.settings_icon,
        title: 'settings'.i18n,
        onTap: () {
          openSettings(context);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();

    return BaseScreen(
      title: 'Account'.i18n,
      body: sessionModel
          .proUser((BuildContext context, bool proUser, Widget? child) {
        return ListView(
          padding: const EdgeInsetsDirectional.only(top: 2, start: 20, end: 20),
          children:
              proUser ? proItems(context) : freeItems(context, sessionModel),
        );
      }),
    );
  }
}
