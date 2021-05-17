import 'package:lantern/package_store.dart';
import 'package:lantern/ui/routes.dart';

import 'settings_item.dart';

class AccountMenu extends StatelessWidget {
  AccountMenu({Key? key}) : super(key: key);

  void openProAccountManagement() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_ACCOUNT_MANAGEMENT);
  }

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

  void openFreeYinbiCrypto() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_FREE_YINBI);
  }

  void openYinbiRedemption() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_YINBI_REDEMPTION);
  }

  void openSettings(BuildContext context) {
    Navigator.pushNamed(context, routeSettings);
  }

  List<Widget> freeItems(BuildContext context) {
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
        icon: ImagePaths.yinbi_icon,
        title: 'free_yinbi_crypto'.i18n,
        onTap: openFreeYinbiCrypto,
      ),
      SettingsItem(
        icon: ImagePaths.settings_icon,
        title: 'settings'.i18n,
        showTopDivider: true,
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
        title: 'pro_account_management'.i18n,
        showArrow: true,
        onTap: openProAccountManagement,
      ),
      SettingsItem(
          icon: ImagePaths.devices_icon,
          title: 'add_device'.i18n,
          showTopDivider: true,
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
        icon: ImagePaths.yinbi_icon,
        title: 'yinbi_redemption'.i18n,
        onTap: openYinbiRedemption,
      ),
      SettingsItem(
        icon: ImagePaths.settings_icon,
        title: 'settings'.i18n,
        showTopDivider: true,
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: proUser ? proItems(context) : freeItems(context),
        );
      }),
    );
  }
}
