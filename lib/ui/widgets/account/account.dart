import 'package:flutter/cupertino.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/settings/settings.dart';
import 'package:lantern/ui/widgets/settings/settings_item.dart';

class AccountTab extends StatelessWidget {
  AccountTab({Key? key}) : super(key: key);

  void onOpenProAccountManagement() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_ACCOUNT_MANAGEMENT);
  }

  void onUpgradeToLanternPro() {
    LanternNavigator.startScreen(
        LanternNavigator.SCREEN_UPGRADE_TO_LANTERN_PRO);
  }

  void onAuthorizeDeviceForPro() {
    LanternNavigator.startScreen(
        LanternNavigator.SCREEN_AUTHORIZE_DEVICE_FOR_PRO);
  }

  void onAddDevice() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_ADD_DEVICE);
  }

  void onInviteFriends() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_INVITE_FRIEND);
  }

  void onOpenDesktopVersion() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_DESKTOP_VERSION);
  }

  void onOpenFreeYinbiCrypto() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_FREE_YINBI);
  }

  void onOpenYinbiRedemption() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_YINBI_REDEMPTION);
  }

  void onOpenSettings(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  List<Widget> freeItems(BuildContext context) {
    return [
      SettingsItem(
        icon: ImagePaths.crown_icon,
        title: 'upgrade_to_lantern_pro'.i18n,
        onTap: onUpgradeToLanternPro,
      ),
      SettingsItem(
        icon: ImagePaths.devices_icon,
        title: 'authorize_device_for_pro'.i18n,
        onTap: onAuthorizeDeviceForPro,
      ),
      SettingsItem(
        icon: ImagePaths.star_icon,
        title: 'invite_friends'.i18n,
        onTap: onInviteFriends,
      ),
      SettingsItem(
        icon: ImagePaths.desktop_icon,
        title: 'desktop_version'.i18n,
        onTap: onOpenDesktopVersion,
      ),
      SettingsItem(
        icon: ImagePaths.yinbi_icon,
        title: 'free_yinbi_crypto'.i18n,
        onTap: onOpenFreeYinbiCrypto,
      ),
      CustomDivider(),
      SettingsItem(
        icon: ImagePaths.settings_icon,
        title: 'settings'.i18n,
        onTap: () {
          onOpenSettings(context);
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
        onTap: onOpenProAccountManagement,
      ),
      const CustomDivider(),
      SettingsItem(
          icon: ImagePaths.devices_icon,
          title: 'add_device'.i18n,
          onTap: onAddDevice),
      SettingsItem(
        icon: ImagePaths.star_icon,
        title: 'invite_friends'.i18n,
        onTap: onInviteFriends,
      ),
      SettingsItem(
        icon: ImagePaths.desktop_icon,
        title: 'desktop_version'.i18n,
        onTap: onOpenDesktopVersion,
      ),
      SettingsItem(
        icon: ImagePaths.yinbi_icon,
        title: 'yinbi_redemption'.i18n,
        onTap: onOpenYinbiRedemption,
      ),
      const CustomDivider(),
      SettingsItem(
        icon: ImagePaths.settings_icon,
        title: 'settings'.i18n,
        onTap: () {
          onOpenSettings(context);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();
    return sessionModel
        .proUser((BuildContext context, bool proUser, Widget? child) {
      return BaseScreen(
        title: 'Account'.i18n,
        body: ListView(
          children: proUser ? proItems(context) : freeItems(context),
        ),
      );
    });
  }
}
